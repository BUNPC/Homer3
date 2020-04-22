% SYNTAX:
% [Aaux, tCCAfilter, rcMap] = hmrR_tCCA(data, aux, probe, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, tCCAfilter)
% UI NAME:
% hmrR_tCCA
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
% INPUTS:
% data - this is the concentration data with dimensions #time points x [HbO/HbR/HbT] x #channels
% aux - this is the auxilliary measurements (# time points x #Aux channels)
% probe - source detector stucture (units should be consistent with rhoSD_ssThresh)
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
% tCCAfilter - filter matrix that was learned from resting state data.
%           Will be freshly trained if input was empty. If flagICRegressors = 1, 
%           then each column corresponds to an indiviudal channel
%           regressor. Otherwise, columns correspond to common regressors
%           for all channels in descending order ranked by canonical correlation coefficient
%
% OUTPUTS:
% Aaux - A matrix of auxilliary regressors (#time points x #Aux regressors)
% tCCAfilter - filter matrix that was learned from resting state data.
%           Will be freshly trained if input was empty. If flagICRegressors = 1, 
%           then each column corresponds to an indiviudal channel
%           regressor. Otherwise, columns correspond to common regressors
%           for all channels in descending order ranked by canonical correlation coefficient
% rcMap - An array of cells (1 x #fNIRS channels) containing
%           aux regressor indices for individual regressor-channel mapping. 
%           Only relevant when flagICRegressors = 1, otherwise rcMap is empty.
%
%
% USAGE OPTIONS:
% [Aaux, tCCAfilter, rcMap] = hmrR_tCCA(data, aux, probe, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, tCCAfilter)
%
%
% PARAMETERS:
% flagtCCA: 1
% flagICRegressors: 0
% tCCAparams: [3 2 0.3] 
% tCCAaux_inx: [1 2 3 4 5 6 7 8]
% rhoSD_ssThresh: 15.0
% tCCAfilter: []

%% COMMENTS/THOUGHTS/QUESTIONS ALEX
% 2) Output canonical correlation coefficients as quality metric? 
% 3) Output fNIRS signal(s)/Aux regressors for visualization/quality control?
% 4) single channel (regressor) feature: regressor channel map currently assumes first half HbO, secon half HbR. CHECK HOW NEEDS TO BE ADAPTED FOR GLM?
% 5) Implement the variable low/bandpass filter coefficients from previous processing stream !!!
%%

function [Aaux, tCCAfilter, rcMap] = hmrR_tCCA(data, aux, probe, flagtCCA, flagICRegressors, tCCAparams, tCCAaux_inx, rhoSD_ssThresh, tCCAfilter)

%% flags and tCCA settings
flags.pcaf =  [0 0]; % no pca of X or AUX
flags.shrink = true; % perform shrinkage in the CCA
flag_conc = true; % if 1 CCA inputs are in conc, if 0 CCA inputs are in intensity
% tCCA parameters
param.tau = tCCAparams(2); %stepsize for embedding in samples (tune to sample frequency!)
timelag = tCCAparams(1);
param.ct = 0;   % correlation threshold for rtcca function, set here to 0 (will be applied later)
% correlation used outside of the rtcc function
ctr = tCCAparams(3);

if flagtCCA
    
    %% prepare data
    % current run\
    for iBlk=1:length(data)
        snirf = SnirfClass(data,stim,aux);
        AUX = snirf.GetAuxiliary();  % CHECK THIS ONE!
        d = snirf.GetDataMatrix();
        SrcPos = probe.GetSrcPos();
        DetPos = probe.GetDetPos();
        t = data_y(iBlk).GetTime();
        fq = 1/(t(2)-t(1));
        ml = data_y(iBlk).GetMeasListSrcDetPairs();
        if isempty(mlActAuto{iBlk})
            mlActAuto{iBlk} = ones(size(ml,1),1);
        end
        mlAct = mlActAuto{iBlk};
    end
    
    %% find the list of short and long distance channels
    lst = 1:size(ml,1);
    rhoSD = zeros(length(lst),1);
    posM = zeros(length(lst),3);
    for iML = 1:length(lst)
        rhoSD(iML) = sum((SrcPos(ml(lst(iML),1),:) - DetPos(ml(lst(iML),2),:)).^2).^0.5;
        posM(iML,:) = (SrcPos(ml(lst(iML),1),:) + DetPos(ml(lst(iML),2),:)) / 2;
    end
    lstSS = lst(find(rhoSD<=rhoSD_ssThresh & mlAct(lst) == 1));
    lstLS = lst(find(rhoSD>rhoSD_ssThresh & mlAct(lst) == 1));
    
    
    %% get long and short channels
    if flag_conc % get short(and active) now in conc
        dod = hmrR_Intensity2OD(d);
        dod = hmrR_BandpassFilt(dod, fq, 0, 0.5);
        dc = hmrR_OD2Conc(dod, SD, [6 6]);
        foo = [squeeze(dc(:,1,:)),squeeze(dc(:,2,:))];    % resize conc to match the size of d, HbO first half, HbR second half
        d_long = [foo(:,lstLS), foo(:,lstLS+size(d,2)/2)]; % first half HbO; second half HbR
        d_short = [foo(:,lstSS), foo(:,lstSS+size(d,2)/2)];   
    else % get d_long and short(and active)
        d_long = [d(:,lstLS), d(:,lstLS+size(d,2)/2)]; % first half 690 nm; second half 830 nm
        d_short = [d(:,lstSS), d(:,lstSS+size(d,2)/2)];
    end
    
    %% Select and prepare aux channels
    % only selected signals
    AUX = AUX(:,tCCAaux_inx);
    % lowpass filter AUX signals
    AUX = hmrR_BandpassFilt(AUX, fq, 0, 0.5);
    % AUX signals + add ss signal if it exists
    if ~isempty(d_short)
        AUX = [AUX, d_short]; % this should be of the current run
    end
    % zscore AUX signals
    AUX = zscore(AUX);
    
    %% DO THE TCCA WORK
    if isempty(tCCAfilter)
        %% if the tCCAfilter variable is empty, learn and put it out (this is the training/resting run)
        % number of embeddings
        param.NumOfEmb = ceil(timelag*fq / sts);
        if flagICRegressors %% learn channel specific filters and regressors
            for cc = 1:size(d_long,2)
                %% perform tCCA with shrinkage for each fNIRS channel
                [REG,  ADD] = rtcca(d_long(:,cc),AUX,param,flags);
                %% save individual regressor and channel map
                % return the reduced number of available regressors
                Aaux(:,cc) = REG(:,1);
                % assemble tCCA filter for channel specific regressors from individual reduced mapping matrices Av
                tCCAfilter(:,cc) = ADD.Av(:,1);
                % save channel-regressor map. First half HbO, second half HbR
                rcMap{cc} = cc;
            end   
        else %% learn common set of regressors for all channels (default)
            %% perform tCCA with shrinkage for all fNIRS channels
            [REG,  ADD] = rtcca(d_long,AUX,param,flags);
            %% save and output tCCA filter.
            %reduce filter matrix with the help of correlation threshold or max number of regressors
            if ctr < 1
                % use only auxiliary tcca components that have correlation > ct
                compindex=find(ADD_trn.ccac>param.ct);
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
            tCCAfilter = ADD.Av(:,compindex);
            % set channel-regressor map to empty (GLM will use all available regressors for all channels)
            rcMap = [];
        end
    else
        %% if the tCCAfilter variable exists, apply the filtering and generate the tCCA regressors
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
                rcMap{cc} = cc;
            end
        else
            rcMap = [];
        end
    end
else
    Aaux = [];
    rcMap = [];
    % tCCAfilter = []; if uncommented, retraining necessary whenever tcca is temporarily flagged out of processing stream
end
