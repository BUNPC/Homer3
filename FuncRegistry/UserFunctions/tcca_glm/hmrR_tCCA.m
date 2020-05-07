% SYNTAX:
% [Aaux, rcMap] = hmrR_tCCA(data, aux, probe, runIdx, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, runIdxResting)
%
% UI NAME:
% User_Friendly_Name_For_hmrR_tCCA
%
% DESCRIPTION:
% This script generates regressors using the regularized temporally embedded
% Canonical Correlation Anlaysis described in detail in von Lühmann, NI,
% 2020. Generated Aaux and rcMap are to be passed as an input to GLM function.
% Reference code:  https://github.com/avolu/tCCA-GLM
%
% If you apply this method or want to learn more about it, please use the following
% CITATION:
% von Lühmann, Alexander, et al. "Improved physiological noise regression
% in fNIRS: A multimodal extension of the General Linear Model using temporally
% embedded Canonical Correlation Analysis." NeuroImage 208 (2020): 116472.
%
% INPUT:
% data - SNIRF data type where dataTimeCourse is concentration data (See SNIRF Spec for more details)
% aux - SNIRF aux type where dataTimeCourse is aux time course data (See SNIRF Spec for more details)
% probe - SNIRF probe type containing source/detector geometry data (See SNIRF Spec for more details)
% runIdx - the index of the run in a multi-run session
% flagtCCA - turns the function on / off
% flagICRegressors - selects regressor generation strategy:
%            0/false - common set of regressors for all fNIRS channels (default)
%            1/true - one individual regressor per fNIRS channel (true)
% tCCAparams - These are the parameters for tCCA function
%            1 - timelag
%            2 - sts: step size
%            3 - ctr: if <1  correlation threshold, if =>1 number of regressors.
%                   Redundant if flagICRegressors = 1;
% tCCAaux_inx -  Indices of the aux channels to be used to generate regressors
% rhoSD_ssThresh - max distance for a short separation measurement. Set =0
%          if you do not want to regress the short separation measurements.
%          Follows the static estimate procedure described in Gagnon et al (2011).
%          NeuroImage, 56(3), 1362?1371.
% runIdxResting - resting state run index
%
% OUTPUTS:
% Aaux - A matrix of auxilliary regressors (#time points x #Aux regressors)
% rcMap - An array of cells (1 x #fNIRS channels) containing
%           aux regressor indices for individual regressor-channel mapping.
%           Only relevant when flagICRegressors = 1, otherwise rcMap is empty.
%
% USAGE OPTIONS:
% User_Friendly_Name_hmrR_tCCA_Concentration_Data: [Aaux, rcMap] = hmrR_tCCA(dc, aux, probe, iRun, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, runIdxResting)
% User_Friendly_Name_hmrR_tCCA_OD_Data: [Aaux, rcMap] = hmrR_tCCA(dod, aux, probe, iRun, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, runIdxResting)
%
%
% PARAMETERS:
% flagtCCA: 1
% flagICRegressors: 0
% tCCAparams: [3 2 0.3]
% tCCAaux_inx: [1 2 3 4 5 6 7 8]
% rhoSD_ssThresh: 15.0
% runIdxResting: 1
%
function [Aaux, rcMap] = hmrR_tCCA(data, aux, probe, runIdx, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, runIdxResting)

%% COMMENTS/THOUGHTS/QUESTIONS ALEX
% 2) Output canonical correlation coefficients as quality metric? 
% 3) Output fNIRS signal(s)/Aux regressors for visualization/quality control?
% 4) single channel (regressor) feature: regressor channel map currently assumes first half HbO, secon half HbR. CHECK HOW NEEDS TO BE ADAPTED FOR GLM?
% 5) Implement the variable low/bandpass filter coefficients from previous processing stream !!!
%%

%% flags and tCCA settings
flags.pcaf =  [0 0]; % no pca of X or AUX
% flags.shrink = true; % perform shrinkage in the CCA
flags.shrink = false;  % JD: set to false because rtcca generate error, "Undefined function or variable 'cshrink'".

% tCCA parameters
param.tau = tCCAparams(2); %stepsize for embedding in samples (tune to sample frequency!)
timelag = tCCAparams(1);
param.ct = 0;   % correlation threshold for rtcca function, set here to 0 (will be applied later)

% correlation used outside of the rtcc function
ctr = tCCAparams(3);

if flagtCCA       
    
    SrcPos  = probe.GetSrcPos();
    DetPos  = probe.GetDetPos();
    
    for iBlk=1:length(data)
        
        % Extract variables from array-of-data-blocks SNIRF arguments, hence the processing 
        % from within the for loop. (see SNIRF spec on github.com for details on data blocks)
        d        = data(iBlk).GetDataTimeSeries('reshape');
        datatype = data(iBlk).GetDataTypeLabel();  % Get the input data type
        t        = data(iBlk).GetTime();
        ml       = data(iBlk).GetMeasListSrcDetPairs();
        
        fq = 1/(t(2)-t(1));
        
        %% find the list of short and long distance channels
        lst = 1:size(ml,1);
        rhoSD = zeros(length(lst),1);
        posM = zeros(length(lst),3);
        for iML = 1:length(lst)
            rhoSD(iML) = sum((SrcPos(ml(lst(iML),1),:) - DetPos(ml(lst(iML),2),:)).^2).^0.5;
            posM(iML,:) = (SrcPos(ml(lst(iML),1),:) + DetPos(ml(lst(iML),2),:)) / 2;
        end
        lstSS = lst(find(rhoSD<=rhoSD_ssThresh)); %#ok<*FNDSB>
        lstLS = lst(find(rhoSD>rhoSD_ssThresh));
               
        %% get long and short separation data        
        if strncmp(datatype{1}, 'Hb', 2)
            dHbO = squeeze(d(:,1,:));
            dHbR = squeeze(d(:,2,:));
            d_short = [dHbO(:,lstSS), dHbR(:,lstSS)];
            d_long  = [dHbO(:,lstLS), dHbR(:,lstLS)];
        elseif strcmp(datatype{1}, 'dOD')
            dWl1 = d(:,1:size(d,2)/2);
            dWl2 = d(:,size(d,2)/2+1:size(d,2));
            d_short = [dWl1(:,lstSS), dWl2(:,lstSS)];
            d_long  = [dWl1(:,lstLS), dWl2(:,lstLS)];
        else
            return;
        end
               
        %% Select and prepare aux channels
        % lowpass filter aux signals from SNIRF aux argument 
        aux = hmrR_BandpassFilt(aux, 0, 0.5);
        % Extract variables from SNIRF aux 
        kk = 1;
        for ii = 1:length(aux)
            % only selected aux channels
            if ismember(ii, tCCAaux_inx)
                AUX(:,kk) = aux(ii).GetDataTimeSeries();
                kk = kk+1;
            end
        end        
        % AUX signals + add ss signal if it exists
        if ~isempty(d_short)
            AUX = [AUX, d_short]; % this should be of the current run
        end
        % zscore AUX signals
        AUX = zscore(AUX);
        
        %% DO THE TCCA WORK
        filterFilename = sprintf('./tCCAfilter_%d.txt', iBlk);
        % number of embeddings
        param.NumOfEmb = ceil(timelag*fq / param.tau);
        if runIdx == runIdxResting
            %% if the tCCAfilter variable is empty, learn and put it out (this is the training/resting run)
            if flagICRegressors %% learn channel specific filters and regressors
                for cc = 1:size(d_long,2)
                    %% perform tCCA with shrinkage for each fNIRS channel
                    [REG,  ADD] = rtcca_dummy(d_long(:,cc),AUX,param,flags);    %%%%%%% JD: rtcca generates error, "Undefined function or variable 'cshrink'". %%%%%%% 
                    %% save individual regressor and channel map
                    % return the reduced number of available regressors
                    Aaux{iBlk}(:,cc) = REG(:,1);
                    % assemble tCCA filter for channel specific regressors from individual reduced mapping matrices Av
                    tCCAfilter(:,cc) = ADD.Av(:,1);
                    % save channel-regressor map. First half HbO, second half HbR
                    rcMap{iBlk}{cc} = cc;
                end
            else %% learn common set of regressors for all channels (default)
                %% perform tCCA with shrinkage for all fNIRS channels
                [REG,  ADD] = rtcca_dummy(d_long,AUX,param,flags);    %%%%%%% JD: rtcca generates error, "Undefined function or variable 'cshrink'". %%%%%%% 
                %% save and output tCCA filter.
                % reduce filter matrix with the help of correlation threshold or max number of regressors
                
                %%%%%%% JD: Undefined variable "ADD_trn" or class "ADD_trn.ccac". %%%%%%% 
                if ctr < 1
                    % use only auxiliary tcca components that have correlation > ct
                    % compindex=find(ADD_trn.ccac>param.ct);
                    compindex=1:10;
                else
                    % use only the first ctr auxiliary tcca components (fixed number of
                    % regressors = ctr)
                    % if numel(ADD_trn.ccac) >= ctr
                    %     compindex = 1:ctr;
                    % else % not as many components available as regressors requested, provide all
                    %     compindex = 1:numel(ADD_trn.ccac);
                    % end                    
                    compindex=1:10;
                end
                % return the reduced number of available regressors
                Aaux{iBlk} = REG(:,compindex);
                % return reduced mapping matrix Av, this is the tCCA filter
                tCCAfilter = ADD.Av(:,compindex);
                
                % set channel-regressor map to empty (GLM will use all available regressors for all channels)
                rcMap{iBlk} = [];
            end
            fprintf('hmrR_tCCA: run idx = %d. Generated and Saved tCCAfilter\n', runIdx)
            print_filter(tCCAfilter);
            save(filterFilename, '-ascii', 'tCCAfilter');
            
        elseif exist(filterFilename,'file')
            
            %% if the tCCAfilter variable exists, apply the filtering and generate the tCCA regressors
            fprintf('hmrR_tCCA: run idx = %d. Loading and Using tCCAfilter\n', runIdx)
            % Load the filter for the iBlk data block
            tCCAfilter = load(filterFilename,'-ascii');
            print_filter(tCCAfilter);
            
            
            % Temporal embedding and zscoring of auxiliary data
            aux_sigs = AUX;
            aux_emb = aux_sigs;
            for i=1:param.NumOfEmb
                aux = circshift(aux_sigs, i*param.tau, 1);
                aux(1:2*i,:) = repmat(aux(2*i+1,:),2*i,1);
                aux_emb = [aux_emb aux];
            end
            %zscore
            % aux_emb = zscore(aux_emb);
            aux_emb = 1;     % JD: Dummy value 
            % Apply tCCA filter (generate regressors)
            Aaux{iBlk} = aux_emb * tCCAfilter;
            % if the individual channel regressor flag was set, indicate by providing rc mapping
            if flagICRegressors
                for cc = 1:size(d_long,2)
                    % save channel-regressor map. First half HbO, second half HbR
                    rcMap{iBlk}{cc} = cc;
                end
            else
                rcMap{iBlk} = [];
            end
        
        else
            
            Aaux{iBlk} = [];
            rcMap{iBlk} = [];
            % tCCAfilter = []; if uncommented, retraining necessary whenever tcca is temporarily flagged out of processing stream
            
        end
        
    end
end




% -----------------------------------------------------------
function print_filter(tCCAfilter)
if exist('pretty_print_matrix.m','file')
    pretty_print_matrix(tCCAfilter, 0, '%0.1f')
else
    fprintf('%d ', tCCAfilter);
    fprintf('\n')
end

