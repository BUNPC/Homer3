% SYNTAX:
% pValues = hmrS_CalcPvalue(yRuns, stimRuns, baselineRange, hrfTimeWindow)
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
% baselineRange:
% hrfTimeWindow:
%
% OUTPUTS:
% pValues:
%
% USAGE OPTIONS:
% Pvalues_on_Session_Concentration_Data: pValues = hmrS_CalcPvalue(dcRuns, stimRuns, baselineRange, hrfTimeWindow)
% Pvalues_on_Session_Delta_OD_Data:      pValues = hmrS_CalcPvalue(dodRuns, stimRuns, baselineRange, hrfTimeWindow)
%
% PARAMETERS:
% baselineRange: [-2.0, 0.0]
% hrfTimeWindow: [-2.0, 20.0]
%
function pValues = hmrS_CalcPvalue(yRuns, stimRuns, mlActAuto, baselineRange, hrfTimeWindow)

pValues = cell(length(yRuns{1}),1);


% extract fq and number of conditions from the first run:
snirf = SnirfClass(yRuns, stimRuns);
% % % % %     snirf = SnirfClass(yRuns{iRun}, stimRuns{iRun});
ml = snirf.GetMeasListSrcDetPairs();
t = snirf.GetTimeCombined();
s = snirf.GetStims(t);
ncond = size(s,2);
fq = abs(1/(t(1)-t(2)));

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
        for iBlk = 1:length(yRuns)
            % get active measuremnt list for each run
            % 1) IS THIS HOW WE EXTRACT MEASLISTACT
            if isempty(mlActAuto{iBlk})
                mlActAuto{iBlk} = ones(size(ml,1),1);
            end
            mlAct = mlActAuto{iBlk};
            % GetDataMatrix() extract data in old homer2 dimensions (time X Hb X channel)
            y = data_y.GetDataMatrix();% yRuns{iRun}(iBlk).GetDataMatrix();  % data matrix for run iRun, data block iBlk
            for hb = 1:3 % across HbO/HbR/HbT
                for iTrial = 1:size(lst_stim,1) % across trials
                    % Hb_SS: # of time points X # of trials X # of runs X # of channels X HbO/HbR
                    Hb_SS_baseline(:,iTrial,iRun,:,hb,cond) = squeeze(y([lst_stim(iTrial) - round(abs(baselineRange(1))*fq)]:lst_stim(iTrial),hb,:)); % get each trial
                    Hb_SS_peak(:,iTrial,iRun,:,hb,cond) = squeeze(y([lst_stim(iTrial) + round(abs(hrfTimeWindow(1))*fq)]:[lst_stim(iTrial) + round(hrfTimeWindow(2)*fq)],hb,:)); % get each trial
                    
                end
            end
        end
        
        % put together trials from all runs:
        Hb_SS_baseline_rs = reshape(Hb_SS_baseline, size(Hb_SS_baseline,1),  size(Hb_SS_baseline,2)* size(Hb_SS_baseline,3),  size(Hb_SS_baseline,4),size(Hb_SS_baseline,5),size(Hb_SS_peak,6));
        Hb_SS_peak_rs = reshape(Hb_SS_peak, size(Hb_SS_peak,1),  size(Hb_SS_peak,2)* size(Hb_SS_peak,3),  size(Hb_SS_peak,4),size(Hb_SS_peak,5),size(Hb_SS_peak,6));
        
        % take the mean in time ranges: baselineRange, hrfTimeWindow
        for hb = 1:3 % HbO/HbR/HbT
            for ch=1:size(Hb_SS_peak_rs,3) % across channels
                MEAN_Hb_SS_baseline(:,ch,hb)= nanmean(squeeze(Hb_SS_baseline_rs(:,:,ch,hb)),1);
                MEAN_Hb_SS_peak(:,ch,hb)= nanmean(squeeze(Hb_SS_peak_rs(:,:,ch,hb)),1);
            end
        end
        
        % get stats
                if isempty(pValues{iBlk})
        for ch = 1:size(MEAN_Hb_SS_peak,2) % channels
            if mlAct(ch) ~=0
                format long
                for hb = 1:3% HbO/HbR/HbT
                    [h,p,c,stats] = ttest(MEAN_Hb_SS_baseline(:,ch,hb),(MEAN_Hb_SS_peak(:,ch,hb)));
                    pValuesS(hb,ch,cond) = p;
                    
                    % 2) Pvalue SHOULD BE CONVERTED TO DATA CLASS IN THE RIGHT DIM AT THE END
                    
                end
            else
                pValuesS(hb,ch,cond) = 'NaN';
            end
        end
                end
        
    end
end