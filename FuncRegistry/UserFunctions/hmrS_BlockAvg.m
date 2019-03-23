function [yAvgOut, yAvgStdOut, nTrials] = hmrS_BlockAvg(yAvgRuns, yAvgStdRuns, ySum2Runs, SDRuns, nTrialsRuns, CondName2Run)
% SYNTAX:
% [yAvg, yAvgStd, tHRF, nTrials] = hmrS_BlockAvg(yAvgRuns, yAvgStdRuns, ySum2Runs, SDRuns, nTrialsRuns, CondName2Run)
%
% UI NAME:
% Block_Average_Subj
%
% DESCRIPTION:
% Calculate the block average for all subjects, for all common stimuli
% accross runs over the time range trange. 
%
% INPUTS:
% yAvgRuns:
% yAvgStdRuns:
% SDRuns:
% nTrialsRuns:
% CondName2Run: 
% trange: defines the range for the block average
% thresh: Threshold for excluding channels if it's data deviates too much
%         from mean 
%
% OUTPUTS:
% yAvgOut: the averaged results
% yAvgStdOut: the standard deviation across trials
% nTrials: the number of trials averaged for each condition across all runs
%
% USAGE OPTIONS:
% Block_Average_on_Subject_Concentration_Data:  [dcAvg, dcAvgStd, nTrials]    = hmrS_BlockAvg(dcAvgRuns, dcAvgStdRuns, dcSum2Runs, SDRuns, nTrialsRuns, CondName2Run)
% Block_Average_on_Subject_Delta_OD_Data:       [dodAvg, dodAvgStd, nTrials]  = hmrS_BlockAvg(dodAvgRuns, dodAvgStdRuns, dodSum2Runs, SDRuns, nTrialsRuns, CondName2Run)
%

yAvgOut    = DataClass();
yAvgStdOut = DataClass();
nTrials    = [];

nTrials_tot = [];
grp1 = [];
for iRun = 1:length(yAvgRuns)      
    for kk = 1:length(yAvgRuns{iRun})
    
        tHRF      = yAvgRuns{iRun}(kk).GetT();
        yAvg      = yAvgRuns{iRun}(kk).GetDataMatrix();
        yAvgStd   = yAvgStdRuns{iRun}(kk).GetDataMatrix();
        ySum2     = ySum2Runs{iRun}(kk).GetDataMatrix();
        nTrials   = nTrialsRuns{iRun};
        SD        = SDRuns{iRun};
        datatype  = unique(yAvgRuns{iRun}(kk).GetDataTypeLabel());
               
        if isempty(yAvg)
            continue;
        end
        
        nCond = size(CondName2Run,2);
        ml = SD.MeasList;
        yAvgOut(kk).SetT(tHRF);
        yAvgStdOut(kk).SetT(tHRF);
        
        if datatype(1)==1
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                nTrials_tot = zeros(size(yAvg,2), nCond);
            end
            
            lstChInc = find(SD.MeasListAct==1);
            for iC = 1:nCond
                iS = CondName2Run(iRun,iC);
                if(iS==0)
                    nT = 0;
                else
                    nT = nTrials(iS);
                end
                
                if nT>0
                    if iRun==1
                        grp1(:,lstChInc,iC) = yAvg(:,lstChInc,iS) * nT;
                        grp1Sum2(:,lstChInc,iC) = ySum2(:,lstChInc,iS);
                        nTrials_tot(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,2)
                            try
                                grp1(:,lstChInc(iCh),iC) = grp1(:,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,lstChInc(iCh),iS),tHRF') * nT;
                            catch
                                d = 1;
                            end
                            grp1Sum2(:,lstChInc(iCh),iC) = grp1Sum2(:,lstChInc(iCh),iC) + interp1(tHRF,ySum2(:,lstChInc(iCh),iS),tHRF');
                            nTrials_tot(lstChInc(iCh),iC) = nTrials_tot(lstChInc(iCh),iC) + nT;
                        end
                    end
                end
            end
            
            if ~isempty(grp1)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,iCh,iC) = grp1(:,iCh,iC) / nTrials_tot(iCh,iC);
                        % ml = MeasListClass(SD.MeasList(iCh,1), SD.MeasList(iCh,2), SD.MeasList(iCh,4));
                        
                        % We want to distinguish between no trials and 1 trial:
                        % If there are no trials, we have no HRF data and no std which
                        % the first case will calculate as opposed to one trial (2nd case)
                        % where we have all zeros.
                        if(nTrials_tot(iCh,iC)~=1)
                            yAvgStd(:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
                        else
                            yAvgStd(:,iCh,iC) = zeros(size(grp1Sum2(:,iCh,iC)));
                        end
                        
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(kk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                            yAvgStdOut(kk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(kk).AppendD(yAvg(:,:,iC));
                        yAvgStdOut(kk).AppendD(yAvgStd(:,:,iC));
                    end
                end
            end
            
        elseif datatype(1)==6 || datatype(1)==7 || datatype(1)==8
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                nTrials_tot = zeros(size(yAvg,3), nCond);
            end
            
            lst1 = find(SD.MeasList(:,4)==1);
            lstChInc = find(SD.MeasListAct(lst1)==1);
            for iC = 1:1:nCond
                iS = CondName2Run(iRun,iC);
                if(iS==0)
                    nT = 0;
                else
                    nT = nTrials(iS);
                end
                
                if nT>0
                    if iRun==1
                        grp1(:,:,lstChInc,iC) = yAvg(:,:,lstChInc,iS) * nT;
                        grp1Sum2(:,:,lstChInc,iC) = ySum2(:,:,lstChInc,iS);
                        nTrials_tot(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,3)
                            for iHb=1:size(yAvg,2)
                                try
                                    grp1(:,iHb,lstChInc(iCh),iC) = grp1(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,iHb,lstChInc(iCh),iS),tHRF') * nT;
                                catch
                                    d=1;
                                end
                                grp1Sum2(:,iHb,lstChInc(iCh),iC) = grp1Sum2(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,ySum2(:,iHb,lstChInc(iCh),iS),tHRF');
                            end
                            nTrials_tot(lstChInc(iCh),iC) = nTrials_tot(lstChInc(iCh),iC) + nT;
                        end
                    end
                end
            end
            
            if ~isempty(grp1)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC);
                        
                        % We want to distinguish between no trials and 1 trial:
                        % If there are no trials, we have no HRF data and no std which
                        % the first case will calculate as opposed to one trial (2nd case)
                        % where we have all zeros.
                        if(nTrials_tot(iCh,iC)~=1)
                            yAvgStd(:,:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
                        else
                            yAvgStd(:,:,iCh,iC) = zeros(size(grp1Sum2(:,:,iCh,iC)));
                        end
                        
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 6, iC);
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 7, iC);
                            yAvgOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 8, iC);
                            yAvgStdOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 6, iC);
                            yAvgStdOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 7, iC);
                            yAvgStdOut(kk).AddChannelDc(ml(iCh,1), ml(iCh,2), 8, iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(kk).AppendD(yAvg(:,:,:,iC));
                        yAvgStdOut(kk).AppendD(yAvgStd(:,:,:,iC));
                    end
                end                
            end            
        end
    end
end
nTrials = nTrials_tot;
    
