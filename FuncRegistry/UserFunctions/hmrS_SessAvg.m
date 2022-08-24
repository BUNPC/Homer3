% SYNTAX:
% [yAvg, nTrials] = hmrS_SessAvg(yAvgSess, mlActSess, nTrialsSess)
%
% UI NAME:
% Sess_Average
%
% DESCRIPTION:
% Calculate avearge HRF of all runs for one subject. 
%
% INPUTS:
% yAvgSess:
% mlActSess:
% nTrialsSess:
%
% OUTPUTS:
% yAvgOut: the averaged results
% nTrials: the number of trials averaged for each condition across all runs
%
% USAGE OPTIONS:
% Sess_Average_on_Concentration_Data:  [dcAvg, nTrials]  = hmrS_SessAvg(dcAvgSess, mlActSess, nTrialsSess)
% Sess_Average_on_Delta_OD_Data:       [dodAvg, nTrials] = hmrS_SessAvg(dodAvgSess, mlActSess, nTrialsSess)
%
function [yAvgOut, nTrials] = hmrS_SessAvg(yAvgSess, mlActSess, nTrialsSess)

yAvgOut    = DataClass().empty();

nDataBlks = length(yAvgSess{1});
nTrials_tot = cell(nDataBlks,1);
err = zeros(nDataBlks, length(yAvgSess));

for iBlk = 1:nDataBlks
    
    grp1 = [];
    
    for iSess = 1:length(yAvgSess)
            
        yAvgOut(iBlk) = DataClass();
        
        yAvg      = yAvgSess{iSess}(iBlk).GetDataTimeSeries('reshape');
        if isempty(yAvg)
            err(iBlk, iSess) = -1;
            continue;
        end
        tHRF      = yAvgSess{iSess}(iBlk).GetTime();
        nTrials   = nTrialsSess{iBlk};
        if isempty(mlActSess{iSess})
            mlActSess{iSess} = cell(length(nDataBlks),1);
        end
        
        % 
        datatype  = yAvgSess{iSess}(iBlk).GetDataTypeLabel();
        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            ml    = yAvgSess{iSess}(iBlk).GetMeasListSrcDetPairs('reshape');
        elseif strcmp(datatype{1}, 'HRF dOD')
            ml    = yAvgSess{iSess}(iBlk).GetMeasList('reshape');
        end
        if isempty(mlActSess{iSess}{iBlk})
            mlActSess{iSess}{iBlk} = ones(size(ml,1),1);
        end
        mlAct = mlActSess{iSess}{iBlk}(1:size(ml,1));
        lstChInc = 1:length(mlAct);
                
        nCond = size(nTrials,2);
        yAvgOut(iBlk).SetTime(tHRF);
        
        if strcmp(datatype{1}, 'HRF dOD')
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,2), nCond);
            end
            
            for iC = 1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iSess==1
                        for iCh = 1:length(lstChInc) %size(yAvg,2)
                            % Check if channel is active or if it was inactive (pruned for whatever reason)
                            if all(isnan(yAvg(:,lstChInc(iCh),iC)))
                                continue;
                            end
                            
                            % Initialize grp1 with 1st session's data
                            grp1(:,lstChInc(iCh),iC) = yAvg(:,lstChInc(iCh),iC) * nT;
                            nTrials_tot{iBlk}(iCh,iC) = nT;
                        end
                    else
                        for iCh = 1:length(lstChInc) %size(yAvg,2)
                            % Check if channel is active or if it was inactive (pruned for whatever reason)
                            if all(isnan(yAvg(:,lstChInc(iCh),iC)))
                                continue;
                            end
                            
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,lstChInc(iCh),iC) = grp1(:,lstChInc(iCh),iC) + interp1(tHRF, yAvg(:,lstChInc(iCh),iC), tHRF(:)) * nT;
                            nTrials_tot{iBlk}(iCh,iC) = nTrials_tot{iBlk}(iCh,iC) + nT;
                        end
                    end
                end
            end
            
            if iSess == length(yAvgSess)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,iCh,iC) = grp1(:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC);
                                                
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        yAvgOut(iBlk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    yAvgOut(iBlk).AppendDataTimeSeries(yAvg(:,:,iC));
                end
            end
            
        elseif strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            
            if isempty(grp1)
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
                nTrials_tot{iBlk} = zeros(size(yAvg,3), nCond);
            end
            
            for iC = 1:1:nCond
                nT = nTrials(iC);
                if nT>0
                    if iSess==1
                        for iCh = 1:length(lstChInc) %size(yAvg,3)
                            for iHb = 1:size(yAvg,2)
                                % Check if channel is active or if it was inactive (pruned for whatever reason)
                                if all(isnan(yAvg(:,iHb,lstChInc(iCh),iC)))
                                    continue;
                                end
                                
                                % Initialize grp1 with 1st session's data
                                grp1(:,iHb,lstChInc(iCh),iC) = yAvg(:,iHb,lstChInc(iCh),iC) * nT;
                            end
                            nTrials_tot{iBlk}(iCh,iC) = nT;
                        end
                    else
                        for iCh = 1:length(lstChInc) %size(yAvg,3)
                            for iHb = 1:size(yAvg,2)
                                % Check if channel is active or if it was inactive (pruned for whatever reason)
                                if all(isnan(yAvg(:,iHb,lstChInc(iCh),iC)))
                                    continue;
                                end
                                
                                % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                                % which matches grp1 dimensions when adding the two.
                                grp1(:,iHb,lstChInc(iCh),iC) = grp1(:,iHb,lstChInc(iCh),iC) + interp1(tHRF,yAvg(:,iHb,lstChInc(iCh),iC),tHRF(:)) * nT;
                            end
                            nTrials_tot{iBlk}(iCh,iC) = nTrials_tot{iBlk}(iCh,iC) + nT;
                        end
                    end
                end
            end
            
            if iSess == length(yAvgSess)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / nTrials_tot{iBlk}(iCh,iC);
                                                
                        %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages. 
                        %%%% Now we can set channel descriptors for avg and standard deviation
                        yAvgOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
                        yAvgOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
                        yAvgOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
                    end
                    
                    %%%% Snirf stuff: Once we get to the last run, we've accumulated our averages.
                    %%%% Now we can set channel descriptors for avg and standard deviation
                    yAvgOut(iBlk).AppendDataTimeSeries(yAvg(:,:,:,iC));
                end                
            end
            
        end
    end
end
nTrials = nTrials_tot;

if all(err<0)
    MessageBox('Warning: All run input to hmrS_SessAvg.m is empty.')
end

