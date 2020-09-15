% SYNTAX:
% [Aaux, rcMap] = hmrR_tCCA(data, aux, probe, runIdx, flagtCCA, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, ss_ch_inx, runIdxResting, tResting)
%
% UI NAME:
% hmrR_tCCA
%
% DESCRIPTION:
% This script generates regressors using the regularized temporally embedded
% Canonical Correlation Anlaysis described in detail in von Lühmann et al. (2020), NeuroImage. 
% If you use this method, please use the following CITATION:
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
% tCCAparams - These are the parameters for tCCA function
%            1 - 1 timelag [s]
%            2 - 2 step size [s]
%            3 - 3 ctr if <1  correlation threshold, if =>1 number of regressors.
%                   Redundant if flagICRegressors = 1;
% tCCAaux_inx -  Indices of the aux channels to be used to generate regressors
% rhoSD_ssThresh - max distance for a short separation measurement. Set =0
%          if you do not want to regress the short separation measurements.
%          Follows the static estimate procedure described in Gagnon et al (2011).
%          NeuroImage, 56(3), 1362?1371.
% ss_ch_inx - short separation channel index, starts from one ends with the
% total number of short separation channels
% runIdxResting - resting state run index
% tResting - start/stop time [s] to use from resting data for tCCA training
%
% OUTPUTS:
% Aaux - A matrix of auxilliary regressors (#time points x #Aux regressors)
% rcMap - Currently always empty or "all". 
%           Under development: Will also provide an array of cells (1 x #fNIRS channels) 
%           containing aux regressor indices for individual regressor-channel mapping.
%           Only relevant when flagICRegressors = 1.
%
% USAGE OPTIONS:
% hmrR_tCCA_Concentration_Data: [Aaux, rcMap] = hmrR_tCCA(dc, aux, probe, iRun, flagtCCA, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, ss_ch_inx, runIdxResting, tResting)
% hmrR_tCCA_OD_Data: [Aaux, rcMap] = hmrR_tCCA(dod, aux, probe, iRun, flagtCCA, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, ss_ch_inx, runIdxResting, tResting)
%
%
% PARAMETERS:
% flagtCCA: 1
% tCCAparams: [3 0.08 0.3]
% tCCAaux_inx: [1 2 3 4 5 6 7 8]
% rhoSD_ssThresh: 15.0
% ss_ch_inx: 0
% runIdxResting: 1
% tResting: [30 210]
%
function [Aaux, rcMap] = hmrR_tCCA(data, aux, probe, runIdx, flagtCCA, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, ss_ch_inx, runIdxResting, tResting)

%% COMMENTS/THOUGHTS/QUESTIONS ALEX
% 2) Output canonical correlation coefficients as quality metric?
% 3) Output fNIRS signal(s)/Aux regressors for visualization/quality control?
%%

%% flags and tCCA settings
flags.pcaf =  [0 0]; % no pca of X or AUX
% flags.shrink = true; % perform shrinkage in the CCA
flags.shrink = false;  % JD: set to false because rtcca generate error, "Undefined function or variable 'cshrink'".
% flagICRegressors - selects regressor generation strategy. (0/false) chooses a common set
% of regressors for all fNIRS channels. (1/true) generates one individual
% regressor per fNIRS channel. This feature is currently under development,
% please do not use it.
flagICRegressors = 0;
% tCCA parameters
tCCAparams(2) = tCCAparams(2)*round(1/abs(data.time(1)-data.time(2)));% Now stepsize in sec converted to # of samples, may
param.tau = tCCAparams(2);  %{old comment by avl: stepsize for embedding in samples (tune to sample frequency!)}
% in case very low sampling rate cause non-integer
if param.tau < 1
    param.tau = 1;
else
    param.tau = round(param.tau);
end
timelag = tCCAparams(1);
param.ct = 0;   % correlation threshold for rtcca function, set here to 0 (will be applied later)

% correlation used outside of the rtcca function
ctr = tCCAparams(3);

%checksum for tCCA filter file
chksm = int16(7*flagICRegressors + sum(11*tCCAparams(:)) + sum(13*tCCAaux_inx(:)) + 17*rhoSD_ssThresh + 19*runIdxResting + sum(23*tResting(:)));

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
        
        if ss_ch_inx ~= 0
            lstSS = lstSS(ss_ch_inx);
        end
        
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
        if ~isempty(d_short) & exist('AUX')
            AUX = [AUX, d_short]; % this should be of the current run
        elseif ss_ch_inx ~= 0
            AUX = d_short;
        else
            msg = 'No auxiliary or short separation measurement to regress out.';
            error(msg)
        end

        % zscore AUX signals
        AUX = zscore(AUX);
        
        param.NumOfEmb = ceil(timelag*fq / tCCAparams(2));
        
        %% DO THE TCCA WORK
        filterFilename = sprintf('./tCCAfilter_%d_%d.txt', iBlk, chksm);
        tCCAexists = isfile(sprintf('./tCCAfilter_%d_%d.txt', iBlk, chksm));
        isTrainingRun = runIdxResting == runIdx;
        if ~tCCAexists && isTrainingRun
            dotCCA = 'train';
        elseif tCCAexists && ~isTrainingRun
            dotCCA = 'apply';
        else
            dotCCA = 'skip';
        end
        
        switch dotCCA
            case 'train'
                %% if the tCCAfilter variable is not existing, learn and save it (this is the training/resting run)
                %       Columns of the tCCA filter matrix correspond to common regressors
                %       for all channels in descending order ranked by canonical correlation coefficient
                %       number of embeddings. If flagICRegressors = 1 (currently N/A), 
                %       each column corresponds to an indiviudal channel regressor. 
                
                % cut data to selected time window before training
                % warning if resting segment is shorter than 1min
                if diff(tResting)<60
                    msgbox('WARNING: tCCA training with less than 60s of data is not recommended!')
                end
                cstrt = find(t>=tResting(1));
                cstp = find(t<=tResting(2));
                cIdx = [cstrt(1):cstp(end)];
                % cut
                d_long = d_long(cIdx,:);
                AUX = AUX(cIdx,:);
                
                if ~flagICRegressors %% learn common set of regressors for all channels (default)
                    %% perform tCCA with shrinkage for all fNIRS channels
                    [REG,  ADD_trn] = rtcca(d_long,AUX,param,flags);                 %% save and output tCCA filter.
                    %reduce filter matrix with the help of correlation threshold or max number of regressors
                    if ctr < 1
                        % use only auxiliary tcca components that have correlation > ct
                        compindex=find(ADD_trn.ccac > ctr);
                        % throw a warning that overfitting might occur if
                        % all regressor's correlations are > ctr
                        if numel(compindex) == numel(ADD_trn.ccac)
                            msgbox('WARNING: All regressors have a canonical correlation larger than your threshold. To avoid overfitting, consider setting the number of regressors to a fixed number ctr = N.')
                        end
                    else
                        % use only the first ctr auxiliary tcca components (fixed number of
                        % regressors = ctr)
                        if numel(ADD_trn.ccac) >= ctr
                            compindex = 1:ctr;
                        else % not as many components available as regressors requested, provide all
                            compindex = 1:numel(ADD_trn.ccac);
                        end
                        
                    end
                    % return the reduced number of available regressors
                    Aaux = REG(:,compindex);
                    % return reduced mapping matrix Av, this is the tCCA filter
                    tCCAfilter = ADD_trn.Av(:,compindex);
                    % set channel-regressor map to empty (GLM will use all available regressors for all channels)
                    rcMap{iBlk} = 'all';
                else %% learn channel specific filters and regressors. UNDER DEVELOPMENT - DO NOT USE
                    for cc = 1:size(d_long,2)/2
                        %% perform tCCA with shrinkage for each fNIRS channel (always HbO and HbR together)
                        [REG,  ADD] = rtcca(d_long(:,cc),AUX,param,flags);
                        %% save individual regressor and channel map
                        % return the reduced number of available regressors
                        Aaux{iBlk}(:,cc) = REG(:,1);
                        % assemble tCCA filter for channel specific regressors from individual reduced mapping matrices Av
                        tCCAfilter(:,cc) = ADD.Av(:,1);
                        % save channel-regressor map. First half HbO, second half HbR
                        rcMap{iBlk}{cc} = cc;
                    end
                    % reshape (HbO first row, HbR second row)
                    rcMap{iBlk} = reshape(rcMap{iBlk},[2,numel(rcMap{iBlk})/2]);
                end
                Aaux = []; % we do not want to use regressors for the resting run (available only for investigative purposes)
                %% save tCCAfilter matrix that was learned from resting state data.
                fprintf('hmrR_tCCA: run idx = %d. Generated and Saved tCCAfilter\n', runIdx)
                save(filterFilename, '-ascii', 'tCCAfilter');
                fprintf('Canonical correlation coefficients of all trained regressors:')
                ADD_trn.ccac(compindex)
            case 'apply'
                %% if the tCCAfilter variable exists, load it, apply the filtering and generate the tCCA regressors
                % Load the filter for the iBlk data block
                fprintf('hmrR_tCCA: run idx = %d. Loading and Using tCCAfilter\n', runIdx)
                tCCAfilter = load(filterFilename,'-ascii');
                
                % Temporal embedding and zscoring of auxiliary data
                aux_sigs = AUX;
                aux_emb = aux_sigs;
                for i=1:param.NumOfEmb
                    aux = circshift(aux_sigs, i*param.tau, 1);
                    aux(1:2*i,:) = repmat(aux(2*i+1,:),2*i,1);
                    aux_emb = [aux_emb aux];
                end
                %zscore
                aux_emb = zscore(aux_emb);
                % Apply tCCA filter (generate regressors)
                Aaux = aux_emb * tCCAfilter;
                % if the individual channel regressor flag was set, indicate by providing rc mapping
                if flagICRegressors
                    for cc = 1:size(d_long,2)
                        % save channel-regressor map. First half HbO, second half HbR
                        rcMap{iBlk}{cc} = cc;
                    end
                    % reshape (HbO first row, HbR second row)
                    rcMap = reshape(rcMap,[2,numel(rcMap)/2]);
                else
                    rcMap{iBlk} = 'all';
                end
            case 'skip'
                Aaux = [];
                rcMap = [];
                %% put a user warning
                if runIdx == runIdxResting-1
                    msgbox('tCCA raining (resting run) is not the first run. Other runs skipped. Please re-run the session for complete results.')
                elseif runIdx > runIdxResting
                    msgbox('no tCCA filter trained. Please run training resting run or whole session first.')
                end
        end
        
    end
else
    Aaux = [];
    rcMap = [];
    % tCCAfilter = []; if uncommented, retraining necessary whenever tcca is temporarily flagged out of processing stream
end




% -----------------------------------------------------------
function print_filter(tCCAfilter)
if exist('pretty_print_matrix.m','file')
    pretty_print_matrix(tCCAfilter, 0, '%0.1f')
else
    fprintf('%d ', tCCAfilter);
    fprintf('\n')
end

