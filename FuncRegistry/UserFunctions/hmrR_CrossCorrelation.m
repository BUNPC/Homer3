% SYNTAX:
% [cc, ml, cc_thresh] = hmrR_CrossCorrelation(data, cc_thresh, plot_on)
%
% UI NAME:
% hmrR_CrossCorrelation
%
% DESCRIPTION:
% This script calculates cross correlation across all channel pairs.
%
%
% INPUTS:
% data - this is the concentration data with dimensions #time points x [HbO/HbR/HbT] x #channels
% cc_thresh - cross correlation theshold, sets any correlation below cc_thresh to 0 in plots (display purpose only)
% plot_on - (1) displays cross correlation for HbO and HbR for each run; (0) no display
%
% OUTPUTS:
% cc -  cross correlation matrix
% ml -  measurement list
% cc_thresh - cross correlation theshold, sets any correlation below cc_thresh to 0 in plots (display purpose only)
%
% USAGE OPTIONS:
% hmrR_CrossCorrelation_conc: [cc, ml, cc_thresh] = hmrR_CrossCorrelation(dc, cc_thresh, plot_on)
%
% PARAMETERS:
% cc_thresh: 0.4
% plot_on: 0
%
% PREREQUISITES:
% GLM_HRF_Drift_SS_Concentration: [dcAvg, dcAvgStd, nTrials, dcNew, dcResid, dcSum2, beta, R, hmrstats] = hmrR_GLM(dc, stim, probe, mlActAuto, Aaux, tIncAuto, rcMap, trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector)


function [cc, ml, cc_thresh] = hmrR_CrossCorrelation(data, cc_thresh, plot_on)

for iBlk=1:length(data)
    y      = data(iBlk).GetDataTimeSeries('reshape');
    ml     = data(iBlk).GetMeasListSrcDetPairs('reshape');
end

% HbO
dc = squeeze(y(:,1,:));
dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
cc(:,:,1) = dc'*dc / length(dc);

% HbR
dc = squeeze(y(:,2,:));
dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
cc(:,:,2) = dc'*dc / length(dc);

%% plot

if plot_on == 1
    nch = length(ml);
    tlabel = '';
    for ii = 1:length(ml)
        tlabel = sprintf( '%s,''%c%d''',tlabel,char(64+ml(ii,1)), ml(ii,2) );
    end
    tlabel(1) = [];
    
    
    % HbO
    figure;
    
    cc0 = cc(:,:,1);
    cc0(find(abs(cc(:,:,1))<cc_thresh))=0;
    
    imagesc(cc0,[-1 1])
    colorbar
    set(gca,'xtick',[1:nch])
    set(gca,'xticklabel',eval(sprintf('{%s}', tlabel)) )
    set(gca,'ytick',[1:nch])
    set(gca,'yticklabel',eval(sprintf('{%s}', tlabel)) )
    title( 'HbO Cross-Correlation')
    
    % HbR
    figure;
    
    cc0 = cc(:,:,2);
    cc0(find(abs(cc(:,:,2))<cc_thresh))=0;
    
    imagesc(cc0,[-1 1])
    colorbar
    set(gca,'xtick',[1:nch])
    set(gca,'xticklabel',eval(sprintf('{%s}', tlabel)) )
    set(gca,'ytick',[1:nch])
    set(gca,'yticklabel',eval(sprintf('{%s}', tlabel)) )
    title( 'HbR Cross-Correlation')
end