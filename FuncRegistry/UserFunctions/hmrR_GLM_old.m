% SYNTAX:
% [yavg, yavgstd, tHRF, nTrials, ynew, yresid, ysum2, beta, R, hmrstats] = hmrR_GLM_old(data, stim, probe, mlActAuto, Aaux, tIncAuto, trange, rcMap, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector)
%
% UI NAME:
% GLM_HRF_Drift_SS
%
% DESCRIPTION:
% This version of GLM is deprecated as of April 2021. It uses basis
% function tau and amplitude defined in the parameters rather than by the
% stim marks themselves.
%
% This script estimates the HRF with options to specify the temporal basis
% function type and corresponding parameters, whether or not to perform
% simultaneous regression of short separation channels, drift order, and
% whether or not to correct for motion artifacts. You can also choose the
% method for solving the GLM matrix equation.
%
%
% INPUTS:
% data - this is the concentration data with dimensions #time points x [HbO/HbR/HbT] x #channels
% stim - stimulation vector (# time points x #conditions)=1 at stim onset otherwise =0
% probe - source detector stucture (units should be consistent with rhoSD_ssThresh)
% mlActAuto -
% Aaux - A matrix of auxilliary regressors (#time points x #Aux channels)
% tIncAuto - a vector (#time points x 1) indicating which data time points
%            are motion (=0) or not (=1)
% rcMap - An array of cells (1 x #fNIRS channels) containing aux regressor
%           indices for individual regressor-channel mapping. Currently
%           only relevant when flagNuisanceRMethod = 3 (tCCA regressors).
% trange - defines the range for the block average [tPre tPost]
% glmSolveMethod - this specifies the GLM solution method to use
%            1. use ordinary least squares (Ye et al (2009). NeuroImage, 44(2), 428?447.)
%            2. use iterative weighted least squares (Barker,
%               Aarabi, Huppert (2013). Biomedical optics express, 4(8), 1366?1379.)
%               Note that we suggest driftOrder=0 for this method as
%               otherwise it can produce spurious results.
% idxBasis - this specifies the type of basis function to use for the HRF
%            1. a consecutive sequence of gaussian functions
%            2. a modified gamma function convolved with a square-wave of
%                duration T. Set T=0 for no convolution.
%                The modified gamma function is
%                (exp(1)*(t-tau).^2/sigma^2) .* exp(-(tHRF-tau).^2/sigma^2)
%            3. a modified gamma function and its derivative convolved
%                with a square-wave of duration T. Set T=0 for no convolution.
%			 4.  GAM function from 3dDeconvolve AFNI convolved with
%                a square-wave of duration T. Set T=0 for no convolution.
% 			         (t/(p*q))^p * exp(p-t/q)
%                Defaults: p=8.6 q=0.547
%                The peak is at time p*q.  The FWHM is about 2.3*sqrt(p)*q.
% paramsBasis - Parameters for the basis function depends on idxBasis
%               idxBasis=1 [stdev step ~ ~ ~ ~] where stdev is the width of the
%                  gaussian and step is the temporal spacing between
%                  consecutive gaussians
%               idxBasis=2. [tau sigma T] applied to both HbO and HbR
%                  or [tau1 sigma1 T1 tau2 sigma2 T2]
%                  where the 1 (2) indicates the parameters for HbO (HbR).
%                  default: 0.1 3.0 10.0 1.8 3.0 10.0
%               idxBasis=3 [tau sigma T] applied to both HbO and HbR
%                  or [tau1 sigma1 T1 tau2 sigma2 T2]
%                  where the 1 (2) indicates the parameters for HbO (HbR).
%               idxBasis=4 [p q T] applied to both HbO and HbR
%                  or [p1 q1 T1 p2 q2 T2]
%                  where the 1 (2) indicates the parameters for HbO (HbR).
% rhoSD_ssThresh - max distance for a short separation measurement. Set =0
%          if you do not want to regress the short separation measurements.
%          Follows the static estimate procedure described in Gagnon et al (2011).
%          NeuroImage, 56(3), 1362?1371.
% flagNuisanceRMethod - 0. if short separation regression is performed with the nearest
%               short separation channel.
%            1. if performed with the short separation channel with the
%               greatest correlation.
%            2. if performed with average of all short separation channels.
%            3. uses tCCA regressors for nuisance regression, in Aaux,
%            mapped by rcMap, provided by hmr_tCCA()
% driftOrder - Polynomial drift correction of this order
% c_vector - Contrast vector, has values 1, -1 or 0. E.g. to contrast cond
%           2 to cond 3 in an experimental paradigm with four conditions, c_vector is
%           [0 1 -1 0]
%
% OUTPUTS:
% yavg - the averaged results
% ystd - the standard deviation across trials
% tHRF - the time vector
% nTrials - the number of trials averaged for each condition
% ynew - the model of the HRF with the residual. That is, it is the data y
%        with the nuasance model parameters removed.
% yresid - the residual between the data y and the GLM fit
% ysum2 - an intermediate matrix for calculating stdev across runs
% beta - the coefficients of the temporal basis function fit for the HRF
%           (#coefficients x HbX x #Channels x #conditions)
% R - the correlation coefficient of the GLM fit to the data
%     (#Channels x HbX)
% hmrstats - outputs t and p values for GLM and the corresponding beta_label and ml
%     (#Betas x #Channels x HbX) for conditions
%     (#Channels x HbX) for contrasts 
%
% USAGE OPTIONS:
% GLM_HRF_Drift_SS_Concentration: [dcAvg, dcAvgStd, nTrials, dcNew, dcResid, dcSum2, beta, R, hmrstats] = hmrR_GLM_old(dc, stim, probe, mlActAuto, Aaux, tIncAuto, rcMap, trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector)
%
% PARAMETERS:
% trange: [-2.0, 20.0]
% glmSolveMethod: 1
% idxBasis: 1
% paramsBasis: [1.0 1.0 0.0 0.0 0.0 0.0], maxnum: 6
% rhoSD_ssThresh: 15.0
% flagNuisanceRMethod: 1
% driftOrder: 3
% c_vector: 0
%
% PREREQUISITES:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc( dod, probe, ppf )

function [data_yavg, data_yavgstd, nTrials, data_ynew, data_yresid, data_ysum2, beta_blks, yR_blks, hmrstats] = ...
    hmrR_GLM_old(data_y, stim, probe, mlActAuto, Aaux, tIncAuto, rcMap, trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector)

% Init output
data_yavg     = DataClass().empty();
data_yavgstd  = DataClass().empty();
data_ynew     = DataClass().empty();
data_ysum2    = DataClass().empty();
data_yresid   = DataClass().empty();
beta_blks     = cell(length(data_y),1);
yR_blks       = cell(length(data_y),1);
beta_label = [];
hmrstats = [];

% Check input args
if isempty(tIncAuto)
    tIncAuto = cell(length(data_y),1);
end
if isempty(mlActAuto)
    mlActAuto = cell(length(data_y),1);
end

% Get stim vector by instantiating temporary SnirfClass object with this
% function's stim argument as input, and then using the SnirfClass object's
% GetStims method to convert stim to the s vector that this function needs.
snirf = SnirfClass(data_y, stim);
t = snirf.GetTimeCombined();
s = snirf.GetStims(t);
nTrials = repmat({zeros(1, size(s,2))}, length(data_y), 1);

for iBlk=1:length(data_y)
    
    data_yavg(iBlk)    = DataClass();
    data_yavgstd(iBlk) = DataClass();
    data_ysum2(iBlk)   = DataClass();
    data_ynew(iBlk)    = DataClass(data_y(iBlk));
    data_yresid(iBlk)  = DataClass(data_y(iBlk));
    
    y      = data_y(iBlk).GetDataTimeSeries('reshape');
    t      = data_y(iBlk).GetTime();
    ml     = data_y(iBlk).GetMeasListSrcDetPairs('reshape');
    SrcPos = probe.GetSrcPos();
    DetPos = probe.GetDetPos();
    
    mlActAuto{iBlk} = mlAct_Initialize(mlActAuto{iBlk}, ml);
    mlAct = mlAct_Matrix2BinaryVector(mlActAuto{iBlk}, ml);
    
    if isempty(tIncAuto{iBlk})
        tIncAuto{iBlk} = ones(length(t),1);
    end
    tInc = tIncAuto{iBlk};
    
    yavg = [];
    yavgstd = [];
    ysum2 = [];
    
    dt = t(2)-t(1);
    nPre = round(trange(1)/dt);
    nPost = round(trange(2)/dt);
    nTpts = size(y,1);
    tHRF = (1*nPre*dt:dt:nPost*dt)';
    ntHRF = length(tHRF);
    nT = length(t);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find corresponding short separation channel for every channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lst = 1:size(ml,1);
    rhoSD = zeros(length(lst),1);
    posM = zeros(length(lst),3);
    for iML = 1:length(lst)
        rhoSD(iML) = sum((SrcPos(ml(lst(iML),1),:) - DetPos(ml(lst(iML),2),:)).^2).^0.5;
        posM(iML,:) = (SrcPos(ml(lst(iML),1),:) + DetPos(ml(lst(iML),2),:)) / 2;
    end
    lstSS = lst(find(rhoSD<=rhoSD_ssThresh & mlAct(lst)==1));
    
    if isempty(lstSS) || (isempty(Aaux) && flagNuisanceRMethod == 3)
        fprintf('There are no short separation channels in this probe ...performing regular deconvolution.\n');
        mlSSlst = 0;
    else
        switch flagNuisanceRMethod
            case 0  % use nearest SS
                for iML = 1:length(lst)
                    rho = sum((ones(length(lstSS),1)*posM(iML,:) - posM(lstSS,:)).^2,2).^0.5;
                    [foo,ii] = min(rho);
                    iNearestSS(iML) = lstSS(ii);
                end
                mlSSlst = unique(iNearestSS);
            case 1 % use SS with highest correlation
                % HbO
                dc = squeeze(y(:,1,:));
                dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
                cc(:,:,1) = dc'*dc / length(dc);
                
                % HbR
                dc = squeeze(y(:,2,:));
                dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
                cc(:,:,2) = dc'*dc / length(dc);
                
                clear dc
                % find short separation channel with highest correlation
                for iML = 1:size(cc,1)
                    % HbO
                    [foo,ii] = max(cc(iML,lstSS,1));
                    iNearestSS(iML,1) = lstSS(ii);
                    % HbR
                    [foo,ii] = max(cc(iML,lstSS,2));
                    iNearestSS(iML,2) = lstSS(ii);
                end
            case 2 % use average of all active SS as regressor
                mlSSlst = 1;
            case 3 % use tCCA regressors and channel map from hmrR_tCCA()
                if ischar(rcMap{iBlk}) % use all regressors for all channels (only one group)
                    mlSSlst = 1;
                elseif iscell(rcMap{iBlk}) % use channel regressor map
                    mlSSlst = 1:size(rcMap,2);
                end
                
                
        end
    end
    
    %%%%%%%%%%%%%%%%
    % Prune good stim
    %%%%%%%%%%%%%%%%
    % handle case of conditions with 0 trials
    lstCond = find(sum(s>0,1)>0);
    nCond = length(lstCond); %size(s,2);
    onset = zeros(nT,nCond);
    nTrials{iBlk} = zeros(nCond,1);
    for iCond = 1:nCond
        lstT = find(s(:,lstCond(iCond))==1);
        lstp = find((lstT+nPre)>=1 & (lstT+nPost)<=nTpts);
        lst = lstT(lstp);
        nTrials{iBlk}(iCond) = length(lst);
        onset(lst+nPre,iCond) = 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Construct the basis functions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if idxBasis==1
        % Gaussians
        gms = paramsBasis(1);
        gstd = paramsBasis(2);
        
        nB = floor((trange(2)-trange(1))/gms)-1;
        tbasis = zeros(ntHRF,nB);
        for b=1:nB
            tbasis(:,b) = exp(-(tHRF-(trange(1)+b*gms)).^2/(2*gstd.^2));
            tbasis(:,b) = tbasis(:,b)./max(tbasis(:,b)); %normalize to 1
        end
        
    elseif idxBasis==2
        % Modified Gamma
        nConc = 2;
        
        nB = 1;
        tbasis = zeros(ntHRF,nB,nConc);
        for iConc = 1:nConc
            tau = paramsBasis((iConc-1)*3+1);
            sigma = paramsBasis((iConc-1)*3+2);
            T = paramsBasis((iConc-1)*3+3);
            
            tbasis(:,1,iConc) = (exp(1)*(tHRF-tau).^2/sigma^2) .* exp( -(tHRF-tau).^2/sigma^2 );
            lstNeg = find(tHRF<0);
            tbasis(lstNeg,1,iConc) = 0;
            
            if tHRF(1)<tau
                tbasis(1:round((tau-tHRF(1))/dt),1,iConc) = 0;
            end
            
            if T>0
                for ii=1:nB
                    foo = conv(tbasis(:,ii,iConc),ones(round(T/dt),1)) / round(T/dt);
                    tbasis(:,ii,iConc) = foo(1:ntHRF,1);
                end
            end
        end
        
    elseif idxBasis==3
        % Modified Gamma and Derivative
        if length(paramsBasis)==3
            nConc = 1;
        elseif length(paramsBasis)==6
            nConc = 2;
        end
        
        nB = 2;
        tbasis=zeros(ntHRF,nB,nConc);
        for iConc = 1:nConc
            tau = paramsBasis((iConc-1)*3+1);
            sigma = paramsBasis((iConc-1)*3+2);
            T = paramsBasis((iConc-1)*3+3);
            
            tbasis(:,1,iConc) = (exp(1)*(tHRF-tau).^2/sigma^2) .* exp( -(tHRF-tau).^2/sigma^2 );
            tbasis(:,2,iConc) = 2*exp(1)*( (tHRF-tau)/sigma^2 - (tHRF-tau).^3/sigma^4 ) .* exp( -(tHRF-tau).^2/sigma^2 );
            
            if tHRF(1)<tau
                tbasis(1:round((tau-tHRF(1))/dt),1:2,iConc) = 0;
            end
            
            if T>0
                for ii=1:nB
                    foo = conv(tbasis(:,ii,iConc),ones(round(T/dt),1)) / round(T/dt);
                    tbasis(:,ii,iConc) = foo(1:ntHRF,1);
                end
            end
        end
        
    elseif idxBasis==4
        % AFNI Gamma function
        if length(paramsBasis)==3
            nConc = 1;
        elseif length(paramsBasis)==6
            nConc = 2;
        end
        
        nB=1;
        tbasis=zeros(ntHRF,nB,nConc);
        for iConc = 1:nConc
            
            p = paramsBasis((iConc-1)*3+1);
            q = paramsBasis((iConc-1)*3+2);
            T = paramsBasis((iConc-1)*3+3);
            
            tbasis(:,1,iConc) = (tHRF/(p*q)).^p.* exp(p-tHRF/q);
            
            if T>0
                foo = conv(tbasis(:,1,iConc),ones(round(T/dt),1)) / round(T/dt);
                tbasis(:,1,iConc) = foo(1:ntHRF,1);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Construct design matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dA=zeros(nT,nB*nCond,2);
    for iConc = 1:2
        iC = 0;
        for iCond=1:nCond
            for b=1:nB
                iC = iC + 1;
                if size(tbasis,3)==1
                    clmn = conv(onset(:,iCond),tbasis(:,b));
                else
                    clmn = conv(onset(:,iCond),tbasis(:,b,iConc));
                end
                clmn = clmn(1:nT);
                dA(:,iC,iConc) = clmn;
                beta_label{b + (iCond-1)*nB} = ['Cond' num2str(iCond)];
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Expand design matrix nth order polynomial for drift correction
    % rescale polynomial to avoid bad conditionning
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xDrift = ones(nT,driftOrder);
    for ii=2:(driftOrder+1)
        xDrift(:,ii) = ([1:nT]').^(ii-1);
        xDrift(:,ii) = xDrift(:,ii) / xDrift(end,ii);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Expand design matrix with Aaux
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nAux = size(Aaux,2);
    if flagNuisanceRMethod == 3
        nAux = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Expand design matrix for Motion Correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if flagMotionCorrect==1
    %         idxMA = find(diff(tInc)==1);  % number of motion artifacts
    %         if isempty(idxMA)
    nMC = 0;
    Amotion = [];
    %         else
    %             nMA = length(idxMA);
    %             nMC = nMA+1;
    %             Amotion = zeros(nT,nMC);
    %             Amotion(1:idxMA(1),1) = 1;
    %             for ii=2:nMA
    %                 Amotion((idxMA(ii-1)+1):idxMA(ii),ii) = 1;
    %             end
    %             Amotion((idxMA(nMA)+1):end,end) = 1;
    %         end
    %     else
    %         nMC = 0;
    %         Amotion = [];
    %     end
    lstInc = find(tInc==1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Final design matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dummy = size(beta_label,2);
    
    switch flagNuisanceRMethod
        case {0,1,2} % short separation
            for iConc=1:2
                A(:,:,iConc)=[dA(:,:,iConc) xDrift Aaux Amotion];
                
                if iConc == 1
                    for ixDrift = 1:size(xDrift,2)
                        beta_label{ixDrift + dummy} = ['xDrift'];
                    end
                    dummy = size(beta_label,2);
                    for iAaux = 1:size(Aaux,2)
                        beta_label{iAaux + dummy} = ['Aux'];
                    end
                    dummy = size(beta_label,2);
                    for iAmotion = 1:size(Amotion,2)
                        beta_label{ixDrift + dummy} = ['Motion'];
                    end
                end
                
            end
        case 3 % tCCA regressor design matrix without Aaux (will be put in in the loop below)
            for iConc=1:2
                A(:,:,iConc)=[dA(:,:,iConc) xDrift Amotion];
                
                if iConc == 1
                    for ixDrift = 1:size(xDrift,2)
                        beta_label{ixDrift + dummy} = ['Drift'];
                    end
                    dummy = size(beta_label,2);
                    for iAmotion = 1:size(Amotion,2)
                        beta_label{ixDrift + dummy} = ['Motion'];
                    end
                end
                
            end
    end
    
    nCh = size(y,3);
    
    % Exit if not enough data to analyze the 3 here is arbitrary.
    % Certainly needs to be larger than 1
    if length(lstInc)<3*size(A,2) | nCond==0
        warning('Not enough data to find a solution')
        yavg    = zeros(ntHRF,nCh,3,nCond);
        yavgstd = zeros(ntHRF,nCh,3,nCond);
        ysum2   = zeros(ntHRF,nCh,3,nCond);
        yresid  = zeros(nT,3,nCh);
        ynew    = zeros(nT,3,nCh);
        
        yavg    = permute(yavg,[1 3 2 4]);
        yavgstd = permute(yavgstd,[1 3 2 4]);
        ysum2   = permute(ysum2,[1 3 2 4]);
        ynew    = y;
        yresid  = zeros(size(y));
        
        beta = [];
        yR = [];
        return
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SOLVE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tb = zeros(nB,nCh,2,nCond);
    % b = zeros(driftOrder+1+nAux,nCh,2);
    yavg    = zeros(ntHRF,nCh,3,nCond);
    yavgstd = zeros(ntHRF,nCh,3,nCond);
    ysum2   = zeros(ntHRF,nCh,3,nCond);
    yresid  = zeros(nT,3,nCh);
    ynew    = zeros(nT,3,nCh);
    yR      = zeros(nCh,3);
    foo     = zeros(nB*nCond+driftOrder+1+nAux+nMC,nCh,2); % 4 extra for 3rd order drift + nAux
    for conc=1:2 %only HbO and HbR
        
        if flagNuisanceRMethod==1 & ~isempty(lstSS) %rhoSD_ssThresh>0
            mlSSlst = unique(iNearestSS(:,conc));
        end
        
        % loop over short separation / nuisance regressor groups
        for iSS = 1:length(mlSSlst)
            
            lstMLtmp = 1:size(ml,1);
            if mlSSlst(iSS)==0
                lstML = lstMLtmp(find(mlAct(lstMLtmp)==1));
                % lstML = 1:size(y,3);
                At = A(:,:,conc);
            elseif flagNuisanceRMethod==0
                lstML = find(iNearestSS(:)==mlSSlst(iSS) & mlAct(lstMLtmp)==1);
                % lstML = find(iNearestSS==mlSSlst(iSS));
                Ass = y(:,conc,mlSSlst(iSS));
                At = [A(:,:,conc) Ass];
                
                if iSS == 1 && conc == 1
                    dummy = size(beta_label,2);
                    for iAss = 1:size(Ass,2)
                        beta_label{iAss + dummy} = ['ShortSep'];
                    end
                end
                
            elseif flagNuisanceRMethod==1
                lstML = find(iNearestSS(:,conc)==mlSSlst(iSS) & mlAct(lstMLtmp)==1);
                % lstML = find(iNearestSS(:,conc)==mlSSlst(iSS));
                Ass = y(:,conc,mlSSlst(iSS));
                At = [A(:,:,conc) Ass];
                
                if iSS == 1 && conc == 1
                    dummy = size(beta_label,2);
                    for iAss = 1:size(Ass,2)
                        beta_label{iAss + dummy} = ['ShortSep'];
                    end
                end
                
            elseif flagNuisanceRMethod==2
                lstML = lstMLtmp(find(mlAct(lstMLtmp)==1));
                % lstML = 1:size(y,3);
                Ass = mean(y(:,conc,lstSS),3);
                At = [A(:,:,conc) Ass];
                
                if iSS == 1 && conc == 1
                    dummy = size(beta_label,2);
                    for iAss = 1:size(Ass,2)
                        beta_label{iAss + dummy} = ['ShortSep'];
                    end
                end
                
            elseif flagNuisanceRMethod==3
                if ischar(rcMap{iBlk}) % no channel map: use all tCCA regressors for one group of all channels
                    lstML = lstMLtmp(find(mlAct(lstMLtmp)==1));
                    At = [A(:,:,conc) Aaux];
                    
                    if iSS == 1 && conc == 1
                        dummy = size(beta_label,2);
                        for iAaux = 1:size(Aaux,2)
                            beta_label{iAaux + dummy} = ['Aux'];
                        end
                    end
                    
                elseif iscell(rcMap{iBlk}) % channel map: each single regressor corresponds to one channel (nCH groups)
                    lstML = lstMLtmp(find(mlAct(rcMap{iBlk}{conc,iSS})==1));
                    Atcca = Aaux{iBlk}(:,rcMap{conc,iSS});
                    At = [A(:,:,conc) Atcca];
                    
                    if iSS == 1 && conc == 1
                        dummy = size(beta_label,2);
                        for iAtcca = 1:size(Atcca,2)
                            beta_label{iAtcca + dummy} = ['tCCA regressor'];
                        end
                    end
                    
                end
            end
            
            if ~isempty(lstML)
                
                %tcheck if the matrix is well conditionned
                ATA=At(lstInc,:)'*At(lstInc,:);
                rco=rcond(full(ATA));
                if rco<10^-14 && rco>10^-25
                    fprintf('Design matrix is poorly scaled...(RCond=%e)\n', rco);
                elseif rco<10^-25
                    fprintf('Design matrix is VERY poorly scaled...(RCond=%e), cannot perform computation\n', rco);
                    yavg = permute(yavg,[1 3 2 4]);
                    yavgstd = permute(yavgstd,[1 3 2 4]);
                    ysum2 = permute(ysum2,[1 3 2 4]);
                    ynew = y;
                    yresid = zeros(size(y));
                    
                    foo = nTrials{iBlk};
                    nTrials{iBlk} = zeros(1,size(s,2));
                    nTrials{iBlk}(lstCond) = foo;
                    
                    foo = yavg;
                    yavg = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
                    yavg(:,:,:,lstCond) = foo;
                    
                    foo = yavgstd;
                    yavgstd = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
                    yavgstd(:,:,:,lstCond) = foo;
                    
                    foo = ysum2;
                    ysum2 = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
                    ysum2(:,:,:,lstCond) = foo;
                    
                    beta = [];
                    return
                end
                
                % Compute pseudo-inverse and deconvolve
                if glmSolveMethod==1 % ~flagUseTed
                    pinvA=ATA\At(lstInc,:)';
                    foo = [];
                    ytmp = y(lstInc,conc,lstML);
                    foo(:,lstML,conc)=pinvA*squeeze(ytmp);
                elseif glmSolveMethod==2
                    % Use the iWLS code from Barker et al
                    foo = [];
                    ytmp = y(lstInc,conc,lstML);
                    for chanIdx=1:length(lstML)
                        ytmp2 = y(lstInc,conc,lstML(chanIdx));
                        [dmoco, beta, tstat, pval0, sigma, CovB, dfe, w, P, f] = ar_glm_final(squeeze(ytmp2),At(lstInc,:));
                        foo(:,lstML(chanIdx),conc)=beta;
                        ytmp(:,1,chanIdx) = dmoco; %We also need to keep my version of "Yvar" and "Bvar"                    
                        
                        yvar(:,lstML(chanIdx),conc)=sigma.^2;
                        bvar(:,lstML(chanIdx),conc)=diag(CovB);  %Note-  I am only keeping the diag terms.  This lets you test if beta != 0,
                        %but in the future the HOMER-2 code needs to be modified to keep the entire cov-beta matrix which you need to test between conditions e.g. if beta(1) ~= beta(2)
                   
                        % GLM stats for each condition
                        tval(:,lstML(chanIdx),conc) = tstat;
                        pval(:,lstML(chanIdx),conc) = pval0;
                    end
                end
                
                % Solution
                for iCond=1:nCond
                    tb(:,lstML,conc,iCond)=foo([1:nB]+(iCond-1)*nB,lstML,conc);
                    %                yavg(:,lstML,conc,lstCond(iCond))=tbasis*tb(:,lstML,conc,lstCond(iCond));
                    if size(tbasis,3)==1
                        yavg(:,lstML,conc,iCond)=tbasis*tb(:,lstML,conc,iCond);
                    else
                        yavg(:,lstML,conc,iCond)=tbasis(:,:,conc)*tb(:,lstML,conc,iCond);
                    end
                end
                
                % Reconstruct y and yresid (y is obtained just from the HRF) and R
                yresid(lstInc,conc,lstML) = ytmp - permute(At(lstInc,:)*foo(:,lstML,conc),[1 3 2]);
                ynew(lstInc,conc,lstML) = permute(dA(lstInc,:,conc)*foo(1:(nB*nCond),lstML,conc),[1 3 2]) + yresid(lstInc,conc,lstML);
                
                yfit = permute(At(lstInc,:)*foo(:,lstML,conc),[1 3 2]);
                for iML=1:length(lstML)
                    yRtmp = corrcoef(ytmp(:,1,iML),yfit(:,1,iML));
                    yR(lstML(iML),conc) = yRtmp(1,2);
                end
                
                % Get error
                if glmSolveMethod==1 %  OLS  ~flagUseTed
                    pAinvAinvD = diag(pinvA*pinvA');
                    yest(:,lstML,conc) = At * foo(:,lstML,conc);
                    yvar(1,lstML,conc) = sum((squeeze(y(:,conc,lstML))-yest(:,lstML,conc)).^2)./(size(y,1)-1); % check this against eq(53) in Ye2009
                    for iCh = 1:length(lstML)
                        
                        % GLM stats for each condition
                        bvar(:,lstML(iCh),conc) = yvar(1,lstML(iCh),conc) * pAinvAinvD;
                        tval(:,lstML(iCh),conc) =  foo(:,lstML(iCh),conc)./sqrt(bvar(:,lstML(iCh),conc));
                        pval(:,lstML(iCh),conc) = 1-tcdf(abs(tval(:,lstML(iCh),conc)),(size(y,1)-1));
                        %
                        
                        % GLM stats for contrast between conditions, given a c_vector exists
                        if nCond > 1
                            if (sum(abs(c_vector)) ~= 0) && (size(c_vector,2) == nCond)
                                
                                if ~exist('cv_extended') == 1
                                    cv_dummy = [];
                                    for m = 1:nCond
                                        cv_dummy = [cv_dummy ones(1,nB)*c_vector(m)];
                                    end
                                    cv_extended = [cv_dummy zeros(1,size(beta_label,2)-size(cv_dummy,2))];
                                end
                                
                                tval_contrast(:,lstML(iCh),conc) = cv_extended * foo(:,lstML(iCh),conc)./sqrt(cv_extended * (pinvA*pinvA') * yvar(:,lstML(iCh),conc) * cv_extended');
                                pval_contrast(:,lstML(iCh),conc) = 1-tcdf(abs(tval_contrast(:,lstML(iCh),conc)),(size(y,1)-1));
                            end
                        end
                        %
                        
                        
                        for iCond=1:nCond
                            if size(tbasis,3)==1
                                yavgstd(:,lstML(iCh),conc,iCond) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis').^0.5;
                            else
                                yavgstd(:,lstML(iCh),conc,iCond) = diag(tbasis(:,:,conc)*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis(:,:,conc)').^0.5;
                            end
                            ysum2(:,lstML(iCh),conc,iCond) = yavgstd(:,lstML(iCh),conc,iCond).^2 + nTrials{iBlk}(iCond)*yavg(:,lstML(iCh),conc,iCond).^2;
                        end
                    end
                    
                elseif glmSolveMethod==2  % WLS
                    
                    yest(:,lstML,conc) = At * foo(:,lstML,conc);
                    for iCh = 1:length(lstML)
                        for iCond=1:nCond
                            if size(tbasis,3)==1
                                yavgstd(:,lstML(iCh),conc,iCond) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis').^0.5;
                            else
                                yavgstd(:,lstML(iCh),conc,iCond) = diag(tbasis(:,:,conc)*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis(:,:,conc)').^0.5;
                            end
                            ysum2(:,lstML(iCh),conc,iCond) = yavgstd(:,lstML(iCh),conc,iCond).^2 + nTrials{iBlk}(iCond)*yavg(:,lstML(iCh),conc,iCond).^2;
                        end
                    end
                    
                end
                
            end % end loop on ~isempty(lstML)
            
        end % end loop on short separation groups
    end
    
    yavg(:,:,3,:) = yavg(:,:,1,:) + yavg(:,:,2,:);
    yavg = permute(yavg,[1 3 2 4]);
    
    yavgstd(:,:,3,:) = yavgstd(:,:,1,:) + yavgstd(:,:,2,:);
    yavgstd = permute(yavgstd,[1 3 2 4]);
    
    ysum2(:,:,3,:) = ysum2(:,:,1,:) + ysum2(:,:,2,:);
    ysum2 = permute(ysum2,[1 3 2 4]);
    
    yresid(:,3,:) = yresid(:,1,:) + yresid(:,2,:);
    
    ynew(:,3,:) = ynew(:,1,:) + ynew(:,2,:);
    
    tb = permute(tb,[1 3 2 4]);
    
    if nPre<0
        for iCond = 1:size(yavg,4)
            for iCh = 1:size(yavg,3)
                for iHb = 1:size(yavg,2)
                    yavg(:,iHb,iCh,iCond) = yavg(:,iHb,iCh,iCond) - ones(size(yavg,1),1)*mean(yavg(1:(-nPre),iHb,iCh,iCond),1);
                end
            end
        end
    end
    
    foo = nTrials{iBlk};
    nTrials{iBlk} = zeros(1,size(s,2));
    nTrials{iBlk}(lstCond) = foo;
    
    foo = yavg;
    yavg = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
    yavg(:,:,:,lstCond) = foo;
    
    foo = yavgstd;
    yavgstd = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
    yavgstd(:,:,:,lstCond) = foo;
    
    foo = ysum2;
    ysum2 = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
    ysum2(:,:,:,lstCond) = foo;
    
    foo = tb;
    beta = zeros(size(foo,1),size(foo,2),size(foo,3),size(s,2));
    beta(:,:,:,lstCond) = foo;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Snirf stuff:
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Add the channels describing the data
    for iCond = 1:size(yavg,4)
        for iCh = 1:size(yavg,3)
            for iHb = 1:size(yavg,2)
                data_yavg(iBlk).AddChannelHb(ml(iCh,1), ml(iCh,2), iHb, iCond);
                data_yavgstd(iBlk).AddChannelHb(ml(iCh,1), ml(iCh,2), iHb, iCond);
                data_ysum2(iBlk).AddChannelHb(ml(iCh,1), ml(iCh,2), iHb, iCond);
            end
        end
    end
    
    % Set data vectors for the averages
    data_yavg(iBlk).AppendDataTimeSeries(yavg);
    data_yavgstd(iBlk).AppendDataTimeSeries(yavgstd);
    data_ysum2(iBlk).AppendDataTimeSeries(ysum2);
    
    % Set tHRF time vectors
    data_yavg(iBlk).SetTime(tHRF, true);
    data_yavgstd(iBlk).SetTime(tHRF, true);
    data_ysum2(iBlk).SetTime(tHRF, true);
    
    % Set data vectors for the dc-parallel data
    data_ynew(iBlk).SetDataTimeSeries(ynew);
    data_yresid(iBlk).SetDataTimeSeries(yresid);
    
    % Set other data blocks
    beta_blks{iBlk} = beta;
    yR_blks{iBlk}   = yR;
    
   % stats struct
    if glmSolveMethod == 1 % for OLS
        % GLM stats for each condition
        if exist('tval')
        hmrstats.beta_label = beta_label;
        hmrstats.tval = tval;
        hmrstats.pval = pval;
        hmrstats.ml = ml;
        end
    else                   % for iWLS
        if exist('tstat')
        hmrstats.beta_label = beta_label;
        hmrstats.tval = tstat;
        hmrstats.pval = pval;
        hmrstats.ml = ml;
        end
    end
    
    % GLM stats for contrast between conditions, if c_vector exists
    if (sum(abs(c_vector)) ~= 0) && (size(c_vector,2) == nCond) && nCond>1
        if exist('tval_contrast')
        hmrstats.tval_contrast = tval_contrast;
        hmrstats.pval_contrast = pval_contrast;
        hmrstats.contrast = c_vector;
        end
    end
    
end