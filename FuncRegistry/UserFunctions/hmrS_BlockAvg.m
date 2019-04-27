% SYNTAX:
% [yAvg, yAvgStd, nTrials] = hmrS_BlockAvg(yAvgRuns, yAvgStdRuns, ySum2Runs, mlActRuns, nTrialsRuns)
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
% mlActRuns:
% nTrialsRuns:
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
% Block_Average_on_Subject_Concentration_Data:  [dcAvg, dcAvgStd, nTrials]    = hmrS_BlockAvg(dcAvgRuns, dcAvgStdRuns, dcSum2Runs, mlActRuns, nTrialsRuns)
% Block_Average_on_Subject_Delta_OD_Data:       [dodAvg, dodAvgStd, nTrials]  = hmrS_BlockAvg(dodAvgRuns, dodAvgStdRuns, dodSum2Runs, mlActRuns, nTrialsRuns)
%

function [yAvgOut, yAvgStdOut, nTrials] = hmrS_BlockAvg(yAvgRuns, yAvgStdRuns, ySum2Runs, mlActRuns, nTrialsRuns)

yAvgOut    = DataClass().empty();
yAvgStdOut = DataClass().empty();

nDataBlks = length(yAvgRuns{1});
nTrials_tot = cell(nDataBlks,1);

for iBlk = 1:nDataBlks
    
    grp1 = [];
    
    for iRun = 1:length(yAvgRuns)
            
        yAvgOut(iBlk) = DataClass();
        yAvgStdOut(iBlk) = DataClass();
        
        yAvg      = yAvgRuns{iRun}(iBlk).GetDataMatrix();
        if isempty(yAvg)
            continue;
        end
        yAvgStd   = yAvgStdRuns{iRun}(iBlk).GetDataMatrix();
        ySum2     = ySum2Runs{iRun}(iBlk).GetDataMatrix();
        tHRF      = yAvgRuns{iRun}(iBlk).GetT();
        nTrials   = nTrialsRuns{iRun}{iBlk};
        if isempty(mlActRuns{iRun})
            mlActRuns{iRun} = cell(length(nDataBlks),1);
        end
        
        % 
        datatype  = unique(yAvgRuns{iRun}(iBlk).GetDataTypeLabel());
        if datatype(1)==6 || datatype(1)==7 || datatype(1)==8
            ml    = yAvgRuns{iRun}(iBlk).GetMeasListSrcDetPairs();
        elseif datatype(1)==1
            ml    = yAvgRuns{iRun}(iBlk).GetMeasList();
        end
        if isempty(mlActRuns{iRun}{iBlk})
            mlActRuns{iRun}{iBlk} = ones(size(ml,1),1);
        end
        mlAct = mlActRuns{iRun}{iBlk}(1:size(ml,1));
                
        if isempty(yAvg)
            continue;
        end
        
        nCond = size(nTrials,2);
        yAvgOut(iBlk).SetT(tHRF);
        yAvgStdOut(iBlk).SetT(tHRF);
        
        if datatype(1)==1
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,2), nCond);
            end
            
            lstChInc = find(mlAct==1);
            for iC = 1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iRun==1
                        grp1(:,lstChInc,iC) = yAvg(:,lstChInc,iC) * nT;
                        grp1Sum2(:,lstChInc,iC) = ySum2(:,lstChInc,iC);
                        nTrials_tot{iBlk}(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,2)
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,lstChInc(iCh),iC) = grp1(:,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,lstChInc(iCh),iC),tHRF(:)) * nT;
                            grp1Sum2(:,lstChInc(iCh),iC) = grp1Sum2(:,lstChInc(iCh),iC) + interp1(tHRF,ySum2(:,lstChInc(iCh),iC),tHRF(:));
                            nTrials_tot{iBlk}(lstChInc(iCh),iC) = nTrials_tot{iBlk}(lstChInc(iCh),iC) + nT;
                        end
                    end
                end
            end
            
            if ~isempty(grp1)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,iCh,iC) = grp1(:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC);
                        
                        % We want to distinguish between no trials and 1 trial:
                        % If there are no trials, we have no HRF data and no std which
                        % the first case will calculate as opposed to one trial (2nd case)
                        % where we have all zeros.
                        if(nTrials_tot{iBlk}(iCh,iC)~=1)
                            yAvgStd(:,iCh,iC) = ( (1/(nTrials_tot{iBlk}(iCh,iC)-1))*grp1Sum2(:,iCh,iC) - (nTrials_tot{iBlk}(iCh,iC)/(nTrials_tot{iBlk}(iCh,iC)-1))*(grp1(:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC)).^2).^0.5 ;
                        else
                            yAvgStd(:,iCh,iC) = zeros(size(grp1Sum2(:,iCh,iC)));
                        end
                        
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(iBlk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                            yAvgStdOut(iBlk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(iBlk).AppendD(yAvg(:,:,iC));
                        yAvgStdOut(iBlk).AppendD(yAvgStd(:,:,iC));
                    end
                end
            end
            
        elseif datatype(1)==6 || datatype(1)==7 || datatype(1)==8
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,3), nCond);
            end
            
            lstChInc = find(mlAct==1);
            for iC = 1:1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iRun==1
                        grp1(:,:,lstChInc,iC) = yAvg(:,:,lstChInc,iC) * nT;
                        grp1Sum2(:,:,lstChInc,iC) = ySum2(:,:,lstChInc,iC);
                        nTrials_tot{iBlk}(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,3)
                            for iHb=1:size(yAvg,2)
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,iHb,lstChInc(iCh),iC) = grp1(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,iHb,lstChInc(iCh),iC),tHRF(:)) * nT;
                                grp1Sum2(:,iHb,lstChInc(iCh),iC) = grp1Sum2(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,ySum2(:,iHb,lstChInc(iCh),iC),tHRF(:));
                            end
                            nTrials_tot{iBlk}(lstChInc(iCh),iC) = nTrials_tot{iBlk}(lstChInc(iCh),iC) + nT;
                        end
                    end
                end
            end
            
            if ~isempty(grp1)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC);
                        
                        % We want to distinguish between no trials and 1 trial:
                        % If there are no trials, we have no HRF data and no std which
                        % the first case will calculate as opposed to one trial (2nd case)
                        % where we have all zeros.
                        if(nTrials_tot{iBlk}(iCh,iC)~=1)
                            yAvgStd(:,:,iCh,iC) = ( (1/(nTrials_tot{iBlk}(iCh,iC)-1))*grp1Sum2(:,:,iCh,iC) - (nTrials_tot{iBlk}(iCh,iC)/(nTrials_tot{iBlk}(iCh,iC)-1))*(grp1(:,:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC)).^2).^0.5 ;
                        else
                            yAvgStd(:,:,iCh,iC) = zeros(size(grp1Sum2(:,:,iCh,iC)));
                        end
                        
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 6, iC);
                            yAvgOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 7, iC);
                            yAvgOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 8, iC);
                            yAvgStdOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 6, iC);
                            yAvgStdOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 7, iC);
                            yAvgStdOut(iBlk).AddChannelDc(ml(iCh,1), ml(iCh,2), 8, iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(iBlk).AppendD(yAvg(:,:,:,iC));
                        yAvgStdOut(iBlk).AppendD(yAvgStd(:,:,:,iC));
                    end
                end                
            end            
        end
    end
end
nTrials = nTrials_tot;
    
