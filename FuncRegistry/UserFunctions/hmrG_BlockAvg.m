function [yAvgOut, yAvgStdOut] = hmrG_BlockAvg(yAvgSubjs, yAvgStdSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
% SYNTAX:
% [yAvgOut, yAvgStdOut, nTrials] = hmrG_BlockAvg(yAvgSubjs, yAvgStdSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
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
% nTrialsSubjs:
% CondName2Subj:
% trange: Defines the range for the block average
% thresh: Threshold for excluding channels if it's data deviates too much
%         from mean
%
% OUTPUTS:
% yAvgOut: the averaged results
% yAvgStdOut: the standard deviation across trials
%
% USAGE OPTIONS:
% Block_Average_on_Group_Concentration_Data: [dcAvg, dcAvgStd] = hmrG_BlockAvg(dcAvgSubjs, dcAvgStdSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
% Block_Average_on_Group_Delta_OD_Data:      [dodAvg, dodAvgStd] = hmrG_BlockAvg(dodAvgSubjs, dodAvgStdSubjs, nTrialsSubjs, CondName2Subj, tRange, thresh)
%
% PARAMETERS:
% tRange: [5.0, 10.0]
% thresh: [5.0]
%

yAvgOut    = DataClass().empty();
yAvgStdOut = DataClass().empty();

nSubj = length(yAvgSubjs);
thresh = thresh * 1e-6;

% chkFlag is a parameter that if true requires, for each channel, ALL corresponding 
% subjects channels to pass before averaging that channel. TBD: Currently we set it to 
% false unconditionally. In the future chkFlag should be a user-settable input parameter.
chkFlag = false;

for kk = 1:length(yAvgSubjs{1})
    
    subjCh = [];
    nStim = 0;
    grp1 = [];
    
    for iSubj = 1:nSubj
        
        yAvgOut(kk) = DataClass();
        yAvgStdOut(kk) = DataClass();
        
        yAvg      = yAvgSubjs{iSubj}(kk).GetDataMatrix();
        if isempty(yAvg)
            continue;
        end
        yAvgStd   = yAvgStdSubjs{iSubj}(kk).GetDataMatrix();
        tHRF      = yAvgSubjs{iSubj}(kk).GetT();
        nTrials   = nTrialsSubjs{iSubj}{kk};
        datatype  = unique(yAvgSubjs{iSubj}(kk).GetDataTypeLabel());
        if datatype(1)==6 || datatype(1)==7 || datatype(1)==8
            ml    = yAvgSubjs{iSubj}(kk).GetMeasListSrcDetPairs();
        elseif datatype(1)==1
            ml    = yAvgSubjs{iSubj}(kk).GetMeasList();
        end
        
        if isempty(yAvg)
            continue;
        end
        
        nCond = size(CondName2Subj,2);        
        yAvgOut(kk).SetT(tHRF);
        yAvgStdOut(kk).SetT(tHRF);
        
        if datatype(1)==6 || datatype(1)==7 || datatype(1)==8
            
            if iSubj==1
                lstT = find(tHRF>=tRange(1) & tHRF<=tRange(2));
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
            end
            
            if isempty(subjCh)
                subjCh = zeros(size(yAvg,3), nCond);
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
                
                if chkFlag==false | length(lstPass)==size(yAvg,3)
                    if iSubj==1 | iC>nStim
                        for iPass=1:length(lstPass)
                            for iHb=1:3
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,iHb,lstPass(iPass),iC) = interp1(tHRF,yAvg(:,iHb,lstPass(iPass),iS),tHRF(:));
                            end
                        end
                        subjCh(size(yAvg,3),iC)=0;
                        nStim = iC;
                    else
                        for iPass=1:length(lstPass)
                            for iHb=1:3
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,iHb,lstPass(iPass),iC) = grp1(:,iHb,lstPass(iPass),iC) + interp1(tHRF,yAvg(:,iHb,lstPass(iPass),iS),tHRF(:));
                            end
                        end
                    end
                    subjCh(lstPass,iC) = subjCh(lstPass,iC) + 1;
                end
            end
            
            yAvg = [];
            if ~isempty(grp1)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / subjCh(iCh,iC);
                        if iSubj == nSubj
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 6, iC);
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 7, iC);
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 8, iC);
                        end
                    end
                end
                if iSubj == nSubj                
                    yAvgOut(kk).AppendD(yAvg);
                end
            end
            
        elseif datatype(1)==1
            
            if iSubj==1
                lstT  = find(tHRF>=tRange(1) & tHRF<=tRange(2));
                grp1 = zeros(size(yAvg,1),size(yAvg,2),nCond);
            end
            
            if isempty(subjCh)
                subjCh = zeros(size(yAvg,2),nCond);
            end
            for iC = 1:nCond
                iS = CondName2Subj(iSubj,iC);
                if iS==0
                    continue;
                end
                
                for iWl = 1:2
                    % Calculate which channels to include and exclude from the group HRF avg,
                    % based on the subjects' standard error and store result in lstPass
                    lstWl = find(ml(:,4)==iWl);
                    lstPass = find( ((squeeze(mean(yAvgStd(lstT,lstWl,iS),1))./sqrt(nTrials(lstWl,iS)'+eps)) <= thresh) &...
                                      nTrials(lstWl,iS)'>0 );
                    lstPass = lstWl(lstPass);
                    
                    if chkFlag==false | length(lstPass)==size(yAvg,2)
                        if iSubj==1 | iC>nStim
                            for iPass=1:length(lstPass)
                                grp1(:,lstPass(iPass),iC) = interp1(tHRF,yAvg(:,lstPass(iPass),iS),tHRF(:));
                            end
                            subjCh(size(yAvg,2),iC)=0;
                            nStim = iC;
                        else
                            for iPass=1:length(lstPass)
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,lstPass(iPass),iC) = grp1(:,lstPass(iPass),iC) + interp1(tHRF,yAvg(:,lstPass(iPass),iS),tHRF(:));
                            end
                        end
                        subjCh(lstPass,iC) = subjCh(lstPass,iC) + 1;
                    end
                end
            end
            
            yAvg = [];
            if ~isempty(grp1)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,:,iC) = grp1(:,:,iC) / subjCh(iCh,iC);                        
                        if iSubj == nSubj
                            yAvgOut(kk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                        end
                    end
                end
                if iSubj == nSubj
                    yAvgOut(kk).AppendD(yAvg);
                end
            end
            
        end
    end
end

% TBD: Calculate Standard deviation
yAvgStd = [];

