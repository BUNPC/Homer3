% SYNTAX:
% [hmrstatsG_contrast] = hmrG_t_paired_contrast(yAvgSubjs, tHRFrange, c_vector)
%
% UI NAME:
% Paired_t-test_contrast
%
% DESCRIPTION:
% Performs a paired t-test between the HRF of two conditions across all subjects.
%
% INPUTS:
% yAvgSubjs:
% tHRFrange: tHRF range for HRF averaging
% c_vector - Contrast vector, has values 1 or 0. E.g. to perform a paired t-test between cond
%           2 and cond 3 in an experimental paradigm with four conditions, c_vector is
%           [0 1 1 0]
%
% OUTPUTS:
% hrmstatsG_contrast: Statistical results from the MATLAB ttest (h,p,c,stats),
%           measurement list (ml) and contrast vector (c_vector)
%
% USAGE OPTIONS:
% Stats_on_Concentration_Data: [hmrstatsG_contrast] = hmrG_t_paired_contrast(dcAvgSubjs, tHRFrange, c_vector)
%
% PARAMETERS:
% tHRFrange: [0, 0]
% c_vector: [0, 0]
%
function  [hmrstatsG_contrast] = hmrG_t_paired_contrast(yAvgSubjs, tHRFrange, c_vector)
hmrstatsG_contrast = [];
nDataBlks = length(yAvgSubjs{1});
nSubj = length(yAvgSubjs);
nCond = find(c_vector);

if ~isempty(nCond)
    
    for iBlk = 1:nDataBlks
        
        for iSubj = 1:nSubj
            
            yAvg      = yAvgSubjs{iSubj}(iBlk).GetDataTimeSeries('reshape');
            
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
            
            for iCond = nCond
                mean_yAvg(iSubj,iCond,:,:) = mean(yAvg(round(fq*(tHRFrange(1) + abs(min(tHRF)))):round(fq*(tHRFrange(2) + abs(min(tHRF)))),:,:,iCond),1);
            end
        end
        
        % get t-stats
        for i = 1:size(yAvg, 2)  % HbO/R/T
            for j = 1:size(yAvg,3) % Channels
                
                [h,p,c,stats] = ttest( mean_yAvg(:,nCond(1),i,j),mean_yAvg(:,nCond(2),i,j));
                pval(i,j) = p;
                hval(i,j) = h;
                cval(i,j,:) = c;
                tstats{i,j} = stats;
            end
        end
    end
    
    
% output
hmrstatsG_contrast.pval = pval;
hmrstatsG_contrast.hval = hval;
hmrstatsG_contrast.cval = cval;
hmrstatsG_contrast.tstats = tstats;
hmrstatsG_contrast.ml = ml;
hmrstatsG_contrast.c_vector = c_vector;    
hmrstatsG_contrast.mean_yAvg = mean_yAvg;
    
end


