% SYNTAX:
% [yAvg, nTrials] = hmrE_RunAvg(yAvgRuns, mlActRuns, nTrialsRuns)
%
% UI NAME:
% Run_Average
%
% DESCRIPTION:
% Calculate avearge HRF of all runs for one subject. 
%
% INPUTS:
% yAvgRuns:
% mlActRuns:
% nTrialsRuns:
%
% OUTPUTS:
% yAvgOut: the averaged results
% nTrials: the number of trials averaged for each condition across all runs
%
% USAGE OPTIONS:
% Run_Average_on_Concentration_Data:  [dcAvg, nTrials]  = hmrE_RunAvg(dcAvgRuns, mlActRuns, nTrialsRuns)
% Run_Average_on_Delta_OD_Data:       [dodAvg, nTrials] = hmrE_RunAvg(dodAvgRuns, mlActRuns, nTrialsRuns)
%
function [yAvgOut, nTrials] = hmrE_RunAvg(yAvgRuns, mlActRuns, nTrialsRuns)

yAvgOut    = DataClass().empty();
nTrials    = {};

% It is not guaranteed that every run has a non-empty DataClass object
% Therefore look for indices only of non-empty run data 
iRunNonEmpty = [];
for iRun = 1:length(yAvgRuns)
    if ~isempty(yAvgRuns{iRun})
        iRunNonEmpty = [iRunNonEmpty, iRun]; %#ok<AGROW>
    end
end

% If iRunNonEmpty is zero then thered is no data to work with hete. Exit.
if isempty(iRunNonEmpty)
    return;
end

nDataBlks = length(yAvgRuns{iRunNonEmpty(1)});
nTrials_tot = cell(nDataBlks,1);
err = zeros(nDataBlks, length(yAvgRuns));
for iBlk = 1:nDataBlks
    
    grp1 = [];
    
    for iRun = iRunNonEmpty
            
        yAvgOut(iBlk) = DataClass();
        
        yAvg      = yAvgRuns{iRun}(iBlk).GetDataTimeSeries('reshape');
        if isempty(yAvg)
            err(iBlk, iRun) = -1;
            continue;
        end
        tHRF      = yAvgRuns{iRun}(iBlk).GetTime();
        nTrials   = nTrialsRuns{iRun}{iBlk};
        if isempty(mlActRuns{iRun})
            mlActRuns{iRun} = cell(length(nDataBlks),1);
        end
        
        % 
        datatype  = yAvgRuns{iRun}(iBlk).GetDataTypeLabel();
        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            ml    = yAvgRuns{iRun}(iBlk).GetMeasListSrcDetPairs();
        elseif strcmp(datatype{1}, 'HRF dOD')
            ml    = yAvgRuns{iRun}(iBlk).GetMeasList();
        end
        if isempty(mlActRuns{iRun}{iBlk})
            mlActRuns{iRun}{iBlk} = ones(size(ml,1),1);
        end
        mlAct = mlActRuns{iRun}{iBlk}(1:size(ml,1));
                
        nCond = size(nTrials,2);
        yAvgOut(iBlk).SetTime(tHRF);
        
        if strcmp(datatype{1}, 'HRF dOD')
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,2), nCond);
            end
            
            lstChInc = find(mlAct==1);
            for iC = 1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iRun==1
                        grp1(:,lstChInc,iC) = yAvg(:,lstChInc,iC) * nT;
                        nTrials_tot{iBlk}(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,2)
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,lstChInc(iCh),iC) = grp1(:,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,lstChInc(iCh),iC),tHRF(:)) * nT;
                            nTrials_tot{iBlk}(lstChInc(iCh),iC) = nTrials_tot{iBlk}(lstChInc(iCh),iC) + nT;
                        end
                    end
                end
            end
            
            if ~isempty(grp1)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,iCh,iC) = grp1(:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC);
                                                
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(iBlk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(iBlk).AppendDataTimeSeries(yAvg(:,:,iC));
                    end
                end
            end
            
        elseif strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,3), nCond);
            end
            
            lstChInc = find(mlAct==1);
            for iC = 1:1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iRun==1
                        grp1(:,:,lstChInc,iC) = yAvg(:,:,lstChInc,iC) * nT;
                        nTrials_tot{iBlk}(lstChInc,iC) = nT;
                    else
                        for iCh=1:length(lstChInc) %size(yAvg,3)
                            for iHb=1:size(yAvg,2)
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,iHb,lstChInc(iCh),iC) = grp1(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,iHb,lstChInc(iCh),iC),tHRF(:)) * nT;
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
                                                
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        if iRun == length(yAvgRuns)
                            yAvgOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
                            yAvgOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
                            yAvgOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
                        end
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    if iRun == length(yAvgRuns)
                        yAvgOut(iBlk).AppendDataTimeSeries(yAvg(:,:,:,iC));
                    end
                end                
            end            
        end
    end
end
nTrials = cell(1,length(nTrials_tot));
for ii = 1:length(nTrials_tot)
    if isempty(nTrials_tot{ii})
        nTrials{ii} = nTrials_tot{ii};
    else
        nTrials{ii} = nTrials_tot{ii}(1,:);
    end
end
if all(err<0)
    MessageBox('Warning: All run input to hmrE_RunAvg.m is empty.')
end

