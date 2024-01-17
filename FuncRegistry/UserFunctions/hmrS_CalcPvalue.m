% SYNTAX:
% [pValuesS, pValuesS_cond]  = hmrS_CalcPvalue(yRuns, stimRuns, mlActRuns, baselineRange, hrfTimeWindow)
%
% UI NAME:
% Pvalues_on_Session
%
% DESCRIPTION:
% Calculate the p-value matrix for a single session.
%
% INPUTS:
% yRuns:
% stimRuns:
% mlActRuns:
% baselineRange:
% hrfTimeWindow:
%
% OUTPUTS:
% pValuesS:
% pValuesS_cond
% USAGE OPTIONS:
% Pvalues_on_Session_Concentration_Data: [pValuesS, pValuesS_cond] = hmrS_CalcPvalue(dcRuns, stimRuns, mlActRuns, baselineRange, hrfTimeWindow)
%
% PARAMETERS:
% baselineRange: [-2.0, 0.0]
% hrfTimeWindow: [-2.0, 20.0]

function [pValuesS, pValuesS_cond] = hmrS_CalcPvalue(yRuns, stimRuns, mlActRuns, baselineRange, hrfTimeWindow)

pValues = cell(length(yRuns{1}),1);


% extract fq and number of conditions from the first run:
snirf = SnirfClass(yRuns{1}, stimRuns{1});
t = snirf.GetTimeCombined();
s = snirf.GetStims(t);
ncond = size(s,2);
fq = abs(1/(t(1)-t(2)));
nDataBlks = length(yRuns{1});

%% BASELINE vs CONDITION, PAIRED T-TEST
for iBlk = 1:nDataBlks
    for cond = 1:ncond % for each condition
        for iRun = 1:length(yRuns)
            
            % Get stim vector by instantiating temporary SnirfClass object with this
            % function's stim argument as input, and then using the SnirfClass object's
            % GetStims method to convert stim to the s vector that this function needs.
            snirf = SnirfClass(yRuns{iRun}, stimRuns{iRun});
            t = snirf.GetTimeCombined();
            s = snirf.GetStims(t);     % stim matrix for run iRun is same for all of a run's data blocks
            
            % extract HRF at baselineRange and at hrfTimeWindow
            lst_stim = find(s(:,cond)==1);
            
            % get active measuremnt list for each run
            if isempty(mlActRuns{iRun})
                mlActRuns{iRun} = cell(length(nDataBlks),1);
            end
            ml    = yRuns{iRun}(iBlk).GetMeasListSrcDetPairs('reshape');
            
            if isempty(mlActRuns{iRun}{iBlk})
                mlActRuns{iRun}{iBlk} = ones(size(ml,1),1);
            end
            mlAct = mlActRuns{iRun}{iBlk}(1:size(ml,1));
            
            % GetDataTimeSeries() extract data in old homer2 dimensions (time X Hb X channel)
            y = yRuns{iRun}(iBlk).GetDataTimeSeries('reshape'); % yRuns{iRun}(iBlk).GetDataTimeSeries('reshape');  % data matrix for run iRun, data block iBlk
            for hb = 1:3 % across HbO/HbR/HbT
                for iTrial = 1:size(lst_stim,1) % across trials
                    % Hb: # of time points X # of trials X # of runs X # of channels X HbO/HbR
                    Hb_baseline(:,iTrial,iRun,:,hb,cond) = squeeze(y([lst_stim(iTrial) - round(abs(baselineRange(1))*fq)]:lst_stim(iTrial),hb,:)); % get each trial
                    Hb_peak(:,iTrial,iRun,:,hb,cond) = squeeze(y([lst_stim(iTrial) + round(abs(hrfTimeWindow(1))*fq)]:[lst_stim(iTrial) + round(hrfTimeWindow(2)*fq)],hb,:)); % get each trial
                    
                end
            end
        end
    end
    
    % put together trials from all runs:
    Hb_baseline_rs = reshape(Hb_baseline, size(Hb_baseline,1),  size(Hb_baseline,2)* size(Hb_baseline,3),  size(Hb_baseline,4),size(Hb_baseline,5),size(Hb_peak,6));
    Hb_peak_rs = reshape(Hb_peak, size(Hb_peak,1),  size(Hb_peak,2)* size(Hb_peak,3),  size(Hb_peak,4),size(Hb_peak,5),size(Hb_peak,6));
    
    % take the mean in time ranges: baselineRange, hrfTimeWindow
    for hb = 1:3 % HbO/HbR/HbT
        for ch=1:size(Hb_peak_rs,3) % across channels
            MEAN_Hb_baseline(:,ch,hb)= nanmean(squeeze(Hb_baseline_rs(:,:,ch,hb)),1);
            MEAN_Hb_peak(:,ch,hb)= nanmean(squeeze(Hb_peak_rs(:,:,ch,hb)),1);
        end
    end
    
    % get stats
    if isempty(pValues{iBlk})
        for ch = 1:size(MEAN_Hb_peak,2) % channels
                 for hb = 1:3% HbO/HbR/HbT
                    [h,p,c,stats] = ttest(MEAN_Hb_baseline(:,ch,hb),(MEAN_Hb_peak(:,ch,hb)));
                    pValuesS(hb,ch,cond) = p;
                    
                    % 2) Pvalue SHOULD BE CONVERTED TO DATA CLASS IN THE RIGHT DIM AT THE END
                    
                end
        end
    end
end

pValuesS(:,find(mlAct==0),:) = NaN;
   



%% CONDITION vs CONDITION, UNPAIRED T-TEST
% get all combinations of conditions
cond_2_comb = sort(combnk(1:ncond,2));
% extract HRF at hrfTimeWindow from the cond combination
for i = 1:ncond
    lst_stim_all{i} = find(s(:,i)==1);
end

for iBlk = 1:length(nDataBlks)
    for comb_inx = 1:size(cond_2_comb,1) % for each condition
        % get current combin.
        foo = cond_2_comb(comb_inx,:);
        
        for iRun = 1:length(yRuns)
            % get active measuremnt list for each run
            if isempty(mlActRuns{iRun})
                mlActRuns{iRun} = cell(length(nDataBlks),1);
            end
            ml = yRuns{iRun}(iBlk).GetMeasListSrcDetPairs('reshape');
            
            if isempty(mlActRuns{iRun}{iBlk})
                mlActRuns{iRun}{iBlk} = ones(size(ml,1),1);
            end
            mlAct = mlActRuns{iRun}{iBlk}(1:size(ml,1));
            
            % GetDataTimeSeries() extract data in old homer2 dimensions (time X Hb X channel)
            y = yRuns{iRun}(iBlk).GetDataTimeSeries('reshape');  % data matrix for run iRun, data block iBlk
            for hb = 1:3 % across HbO/HbR/HbT
                for iTrial = 1:size(lst_stim_all{foo(1)},1) % across trials
                    % Hb: # of time points X # of trials X # of runs X # of channels X HbO/HbR
                    Hb_peak1(:,iTrial,iRun,:,hb) = squeeze(y([lst_stim_all{foo(1)}(iTrial) + round(abs(hrfTimeWindow(1))*fq)]:[lst_stim_all{foo(1)}(iTrial) + round(hrfTimeWindow(2)*fq)],hb,:)); % get each trial
                end
                for iTrial = 1:size(lst_stim_all{foo(2)},1) % across trials
                    % Hb: # of time points X # of trials X # of runs X # of channels X HbO/HbR
                    Hb_peak2(:,iTrial,iRun,:,hb) = squeeze(y([lst_stim_all{foo(2)}(iTrial) + round(abs(hrfTimeWindow(1))*fq)]:[lst_stim_all{foo(2)}(iTrial) + round(hrfTimeWindow(2)*fq)],hb,:)); % get each trial
                end
            end
        end
    end
    
    % put together trials from all runs:
    Hb_peak_rs1 = reshape(Hb_peak1, size(Hb_peak1,1),  size(Hb_peak1,2)* size(Hb_peak1,3),  size(Hb_peak1,4),size(Hb_peak1,5));
    Hb_peak_rs2 = reshape(Hb_peak2, size(Hb_peak2,1),  size(Hb_peak2,2)* size(Hb_peak2,3),  size(Hb_peak2,4),size(Hb_peak2,5));
    
    % take the mean in time range hrfTimeWindow
    for hb = 1:3 % HbO/HbR/HbT
        for ch=1:size(Hb_peak_rs,3) % across channels
            MEAN_Hb_peak1(:,ch,hb)= nanmean(squeeze(Hb_peak_rs1(:,:,ch,hb)),1);
            MEAN_Hb_peak2(:,ch,hb)= nanmean(squeeze(Hb_peak_rs2(:,:,ch,hb)),1);
            
        end
    end
    
    % get stats
    if ~exist('pValuesS_cond')
        for ch = 1:size(MEAN_Hb_peak,2) % channels
                for hb = 1:3% HbO/HbR/HbT
                    [h,p,c,stats] = ttest2(MEAN_Hb_peak1(:,ch,hb),(MEAN_Hb_peak2(:,ch,hb)));
                    pValuesS_cond(hb,ch,comb_inx) = p;
                    % or                     pValuesS_cond(foo(1),foo(2),hb,ch) = p;
                    
                    % 2) Pvalue SHOULD BE CONVERTED TO DATA CLASS IN THE RIGHT DIM AT THE END
                    
                end
        end
    end
end
pValuesS_cond(:,find(mlAct==0),:) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
