% SYNTAX:
% [hmrstatsG_base_cond] = hmrG_t_paired_baseline_HRF(yAvgSubjs, tHRFrange, cond)
%
% UI NAME:
% Paired_t-test_baseline_vs_HRF
%
% DESCRIPTION:
% Performs a paired t-test between baseline and the mean HRF for a single condition across all subjects
%
% INPUTS:
% yAvgSubjs:
% tHRFrange: tHRF range for HRF averaging
%
% OUTPUTS:
% hmrstatsG_base_cond: Statistical results from the MATLAB ttest (h,p,c,stats) and measurement list (ml)
%
% USAGE OPTIONS:
% Stats_on_Concentration_Data: [hmrstatsG_base_cond] = hmrG_t_paired_baseline_HRF(dcAvgSubjs, tHRFrange, cond)
%
% PARAMETERS:
% tHRFrange: [0, 0]
%
function  [hmrstatsG_base_cond] = hmrG_t_paired_baseline_HRF(yAvgSubjs, tHRFrange)
hmrstatsG_base_cond = [];
nDataBlks = length(yAvgSubjs{1});
nSubj = length(yAvgSubjs);


for iBlk = 1:nDataBlks
    
    for iSubj = 1:nSubj
        
        yAvg      = yAvgSubjs{iSubj}(iBlk).GetDataTimeSeries('reshape');
        ncond = size(yAvg,4);
        
        if iSubj == 1
            tHRF      = yAvgSubjs{iSubj}(iBlk).GetTime();
            fq = abs(1/(tHRF(1)-tHRF(2)));
            ml    = yAvgSubjs{iSubj}(iBlk).GetMeasListSrcDetPairs();
            
            % error check
            if tHRFrange(1)>max(tHRF) || tHRFrange(2)>max(tHRF) || tHRFrange(1)>=tHRFrange(2)
                warning('tHRF range should be between 0 and tHRF max');
                return
            end
        end
        
        baseline_yAvg(iSubj,:,:,:) = squeeze(mean(yAvg(1:round(fq*abs(min(tHRF))),:,:,:),1));
        mean_yAvg(iSubj,:,:,:) = squeeze(mean(yAvg(round(fq*(tHRFrange(1) + abs(min(tHRF)))):round(fq*(tHRFrange(2) + abs(min(tHRF)))),:,:,:),1));
        
    end
    
    % get t-stats
    for iCond = 1:ncond
        for i = 1:size(yAvg, 2)  % HbO/R/T
            for j = 1:size(yAvg,3) % Channels
                
                [h,p,c,stats] = ttest(mean_yAvg(:,i,j,iCond),baseline_yAvg(:,i,j,iCond));
                pval(i,j,iCond) = p;
                hval(i,j,iCond) = h;
                cval(i,j,iCond,:) = c;
                tstats{i,j,iCond} = stats;
                
            end
        end
    end
    
    % output
    hmrstatsG_base_cond.pval = pval;
    hmrstatsG_base_cond.hval = hval;
    hmrstatsG_base_cond.cval = cval;
    hmrstatsG_base_cond.tstats = tstats;
    hmrstatsG_base_cond.ml = ml;
    hmrstatsG_base_cond.mean_yAvg = mean_yAvg;
    
end


