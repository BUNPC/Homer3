function [yAvg, yAvgStd, tHRF, nTrials, grpAvgPass] = hmrG_BlockAvg_Nirs(yAvgSubjs, yAvgStdSubjs, tHRFSubjs, SDSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
% SYNTAX:
% [yAvg, yAvgStd, tHRF, nTrials, grpAvgPass] = hmrG_BlockAvg_Nirs(yAvgSubjs, yAvgStdSubjs, tHRFSubjs, SDSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
%
% UI NAME:
% Block_Average_Group
%
% DESCRIPTION:
% Calculate the block average for all subjects, for all common stimuli accross subjects
% over the time range trange. 
%
% INPUTS:
% yAvgSubjs:
% yAvgStdSubjs:
% tHRFSubjs: 
% SDSubjs:
% nTrialsSubjs:
% CondName2Subj: 
% trange: Defines the range for the block average
% thresh: Threshold for excluding channels if it's data deviates too much
%         from mean 
%
% OUTPUTS:
% yavg: the averaged results
% yAvgStd: the standard deviation across trials
% tHRF: the time vector
% nTrials: the number of trials averaged for each condition across all
%          subjects
% grpAvgPass:
%
% USAGE OPTIONS:
% Block_Average_on_Group_Concentration_Data: [dcAvg, dcAvgStd, tHRF, nTrials, grpAvgPass] = hmrG_BlockAvg_Nirs(dcAvgSubjs, dcAvgStdSubjs, tHRFSubjs, SDSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
% Block_Average_on_Group_Delta_OD_Data:      [dodAvg, dodAvgStd, tHRF, nTrials, grpAvgPass] = hmrG_BlockAvg_Nirs(dodAvgSubjs, dodAvgStdSubjs, tHRFSubjs, SDSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
%
% PARAMETERS:
% tRange: [5.0, 10.0]
% thresh: [5.0]
%

yAvg       = [];
yAvgStd    = [];
tHRF       = [];
nTrials    = [];
grpAvgPass = [];
    
subjCh = [];
nStim = 0;
grp1=[];
nSubj = length(yAvgSubjs);
thresh = thresh * 1e-6;
for iSubj = 1:nSubj
    
    if isempty(yAvgSubjs{iSubj}) || isempty(yAvgStdSubjs{iSubj}) || isempty(tHRFSubjs{iSubj}) || isempty(nTrialsSubjs{iSubj}) || isempty(SDSubjs{iSubj})
        continue;
    end
    
    yAvg      = yAvgSubjs{iSubj};
    yAvgStd   = yAvgStdSubjs{iSubj};
    tHRF      = tHRFSubjs{iSubj};
    nTrials   = nTrialsSubjs{iSubj};
    SD        = SDSubjs{iSubj};
        
    nCond = size(CondName2Subj,2);
    
    if ndims(yAvg) == (4-(nCond<2))
        
        if iSubj==1
            lstT = find(tHRF>=tRange(1) & tHRF<=tRange(2));
            grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
        end
        
        if isempty(subjCh)
            subjCh = zeros(size(yAvg,3), nCond);
            grpAvgPass = zeros(size(yAvg,3), nCond, nSubj);
        end
        
        for iC = 1:nCond
            iS = CondName2Subj(iSubj,iC);            
            if iS==0
                continue;
            end
            
            % Calculate which channels to include and exclude from the group HRF avg,
            % based on the subjects' standard error and store result in lstPass
            % also need to consider if channel was manually or
            % automatically included
            lstPass = find( (squeeze(mean(yAvgStd(lstT,1,:,iS),1))./sqrt(nTrials(:,iS)+eps)) <= thresh &...
                            (squeeze(mean(yAvgStd(lstT,2,:,iS),1))./sqrt(nTrials(:,iS)+eps)) <= thresh &...
                            nTrials(:,iS)>0 );
            
            if length(lstPass)==size(yAvg,3)
                if iSubj==1 | iC>nStim
                    for iPass=1:length(lstPass)
                        for iHb=1:3
                            grp1(:,iHb,lstPass(iPass),iC) = interp1(tHRF,yAvg(:,iHb,lstPass(iPass),iS),tHRF');
                        end
                    end
                    subjCh(size(yAvg,3),iC)=0;
                    nStim = iC;
                else
                    for iPass=1:length(lstPass)
                        for iHb=1:3
                            grp1(:,iHb,lstPass(iPass),iC) = grp1(:,iHb,lstPass(iPass),iC) + interp1(tHRF,yAvg(:,iHb,lstPass(iPass),iS),tHRF');
                        end
                    end
                end
                subjCh(lstPass,iC) = subjCh(lstPass,iC) + 1;
            end
            grpAvgPass(lstPass,iC,iSubj) = 1;
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
            lstT  = find(tHRF>=tRange(1) & tHRF<=tRange(2));
            grp1 = zeros(size(yAvg,1),size(yAvg,2),nCond);
        end
        
        if isempty(subjCh)
            subjCh = zeros(size(yAvg,2),nCond);
            grpAvgPass = zeros(size(yAvg,2),nCond,nSubj);
        end
        for iC = 1:nCond
            iS = CondName2Subj(iSubj,iC);
            if iS==0
                continue;
            end
            
            for iWl = 1:2
                % Calculate which channels to include and exclude from the group HRF avg,
                % based on the subjects' standard error and store result in lstPass
                lstWl = find(SD.MeasList(:,4)==iWl);
                lstPass = find( ((squeeze(mean(yAvgStd(lstT,lstWl,iS),1))./sqrt(nTrials(lstWl,iS)'+eps)) <= thresh) &...
                                 nTrials(lstWl,iS)'>0 );
                lstPass = lstWl(lstPass);
                
                if length(lstPass)==size(yAvg,3)
                    if iSubj==1 | iC>nStim
                        for iPass=1:length(lstPass)
                            grp1(:,lstPass(iPass),iC) = interp1(tHRF,yAvg(:,lstPass(iPass),iS),tHRF');
                        end
                        subjCh(size(yAvg,2),iC)=0;
                        nStim = iC;
                    else
                        for iPass=1:length(lstPass)
                            grp1(:,lstPass(iPass),iC) = grp1(:,lstPass(iPass),iC) + interp1(tHRF,yAvg(:,lstPass(iPass),iS),tHRF');
                        end
                    end
                    subjCh(lstPass,iC) = subjCh(lstPass,iC) + 1;
                end
            end
            grpAvgPass(lstPass,iC,iSubj) = 1;
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
            grpAvgPass = grpAvgPass(1:size(yAvg,2)/2 ,:,:);            
        end
        
    end
end

% TBD: Calculate Standard deviation
yAvgStd = [];

