function [yAvg, tHRF, nTrials] = hmrG_SubjAvg_Nirs(yAvgSubjs, tHRFSubjs, nTrialsSubjs)
% SYNTAX:
% [yAvg, tHRF, nTrials] = hmrG_SubjAvg_Nirs(yAvgSubjs, tHRFSubjs, nTrialsSubjs)
%
% UI NAME:
% Subj_Average
%
% DESCRIPTION:
% Calculate avearge HRF of all subjects in a group . 
%
% INPUTS:
% yAvgSubjs:
% tHRFSubjs: 
% nTrialsSubjs:
%
% OUTPUTS:
% yavg: the averaged results
% tHRF: the time vector
% nTrials: the number of trials averaged for each condition across all
%          subjects
%
% USAGE OPTIONS:
% Subj_Average_on_Concentration_Data: [dcAvg, tHRF, nTrials] = hmrG_SubjAvg_Nirs(dcAvgSubjs, tHRFSubjs, nTrialsSubjs)
% Subj_Average_on_Delta_OD_Data:      [dodAvg, tHRF, nTrials] = hmrG_SubjAvg_Nirs(dodAvgSubjs, tHRFSubjs, nTrialsSubjs)
%
%

yAvg       = [];
tHRF       = [];
nTrials    = [];
    
subjCh = [];
nStim = 0;
grp1=[];
nSubj = length(yAvgSubjs);

for iSubj = 1:nSubj
    
    if isempty(yAvgSubjs{iSubj}) || isempty(tHRFSubjs{iSubj}) || isempty(nTrialsSubjs{iSubj})
        continue;
    end
    
    yAvg      = yAvgSubjs{iSubj};
    tHRF      = tHRFSubjs{iSubj};
    nTrials   = nTrialsSubjs{iSubj};
        
    nCond = size(nTrials,2);
    
    if ndims(yAvg) == (4-(nCond<2))
        
        if iSubj==1
            grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
        end
        
        nCh  = size(yAvg,3);
        if isempty(subjCh)
            subjCh = zeros(nCh, nCond);
        end
        
        for iC = 1:nCond
            if nTrials(:,iC)==0
                continue;
            end
            
            if iSubj==1 | iC>nStim
                for iCh = 1:size(yAvg,3)
                    for iHb=1:3
                        grp1(:,iHb,iCh,iC) = interp1(tHRF,yAvg(:,iHb,iCh,iC),tHRF(:));
                    end
                end
                nStim = iC;
            else
                for iCh = 1:size(yAvg,3)
                    for iHb=1:3
                        grp1(:,iHb,iCh,iC) = grp1(:,iHb,iCh,iC) + interp1(tHRF,yAvg(:,iHb,iCh,iC),tHRF(:));
                    end
                end
            end
            subjCh(:,iC) = subjCh(:,iC) + 1; %#ok<*AGROW>
        end
        
        yAvg = [];
        if ~isempty(grp1)
            for iC = 1:size(grp1,4)
                for iCh = 1:size(grp1,3)
                    yAvg(:,1,iCh,iC) = grp1(:,1,iCh,iC) / subjCh(iCh,iC);
                    yAvg(:,2,iCh,iC) = grp1(:,2,iCh,iC) / subjCh(iCh,iC);
                    yAvg(:,3,iCh,iC) = grp1(:,3,iCh,iC) / subjCh(iCh,iC);
                end
            end
        end
        
    elseif ndims(yAvg) == (3-(nCond<2))
        
        if iSubj==1
            grp1 = zeros(size(yAvg,1),size(yAvg,2),nCond);
        end
        
        nCh  = size(yAvg,2);
        if isempty(subjCh)
            subjCh = zeros(nCh, nCond);
        end
        
        for iC = 1:nCond
            if nTrials(:,iC)==0
                continue;
            end
            
            for iWl = 1:2
                if iSubj==1 | iC>nStim
                    for iCh = 1:size(yAvg,2)
                        grp1(:,iCh,iC) = interp1(tHRF,yAvg(:,iCh,iC),tHRF(:));
                    end
                    nStim = iC;
                else
                    for iCh = 1:size(yAvg,3)
                        grp1(:,iCh,iC) = grp1(:,iCh,iC) + interp1(tHRF,yAvg(:,iCh,iC),tHRF(:));
                    end
                end
                subjCh(:,iC) = subjCh(:,iC) + 1;
            end
        end
        
        yAvg = [];
        if ~isempty(grp1)
            for iC = 1:size(grp1,3)
                for iCh = 1:size(grp1,2)
                    yAvg(:,iCh,iC) = grp1(:,iCh,iC) / subjCh(iCh,iC);
                    yAvg(:,iCh,iC) = grp1(:,iCh,iC) / subjCh(iCh,iC);
                    yAvg(:,iCh,iC) = grp1(:,iCh,iC) / subjCh(iCh,iC);
                end
            end            
        end
        
    end
end
