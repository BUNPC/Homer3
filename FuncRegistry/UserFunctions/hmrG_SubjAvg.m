% SYNTAX:
% [yAvgOut, nTrials] = hmrG_SubjAvg(yAvgSubjs, nTrialsSubjs)
%
% UI NAME:
% Subj_Average
%
% DESCRIPTION:
% Calculate the block average for all subjects, for all common stimuli accross subjects.
%
% INPUTS:
% yAvgSubjs:    cell array of length nSubj containing DataClass objects
%               with the averaged results per subject
% nTrialsSubjs: nSubj x nDataBlks cell array containing the number of 
%               trials per subject per block
%
% OUTPUTS:
% yAvgOut: the averaged results
% nTrials: amount of trials per block over which the average was computed
%
% USAGE OPTIONS:
% Subj_Average_on_Concentration_Data: [dcAvg, nTrials] = hmrG_SubjAvg(dcAvgSubjs, nTrialsSubjs)
% Subj_Average_on_Delta_OD_Data:      [dodAvg, nTrials] = hmrG_SubjAvg(dodAvgSubjs, nTrialsSubjs)
%
%
function [yAvgOut, nTrials] = hmrG_SubjAvg(yAvgSubjs, nTrialsSubjs)

yAvgOut = DataClass().empty();
nDataBlks = length(yAvgSubjs{1});
nTrials = [];
nSubj = length(yAvgSubjs);
err = zeros(nDataBlks, length(yAvgSubjs));

for iBlk = 1:nDataBlks
    
    subjCh = [];
    nStim = 0;
    grp1 = [];
    nT = []; % number of trials
    
    for iSubj = 1:nSubj
        
        yAvgOut(iBlk) = DataClass();        
        
        % get current subject input for the current data block
        yAvg      = yAvgSubjs{iSubj}(iBlk).GetDataTimeSeries('reshape');
        if isempty(yAvg) % if no input, create flag and skip subject
            err(iBlk, iSubj) = -1;
            continue;
        end
        
        tHRF      = yAvgSubjs{iSubj}(iBlk).GetTime();
        nT        = nTrialsSubjs{iSubj}{iBlk};  % get number of trials in this block
        datatype  = yAvgSubjs{iSubj}(iBlk).GetDataTypeLabel();  % check if Hb or OD data
        
        % check if the trial contains Hb or OD data
        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            % get source-detector pairs (renders nChans x 2 matrix; 
            % 1st column contains source indeces, 2nd column contains dectector indices)
            ml    = yAvgSubjs{iSubj}(iBlk).GetMeasListSrcDetPairs();
        elseif strcmp(datatype{1}, 'HRF dOD')
            ml    = yAvgSubjs{iSubj}(iBlk).GetMeasList();
        end
                
        nCond = size(nT,2);  % number of conditions to average over
        yAvgOut(iBlk).SetTime(tHRF);
        

        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))            
            if iSubj==1
                % initialize data array for group 1 with HbO, HbR and 
                % HbT data per condition
                % shape: time x 3 x nChan x nCond (second dim includes the
                % three Hb data typeS)                
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
            end
            
            nCh  = size(yAvg,3);
            if isempty(subjCh)
                subjCh = zeros(nCh, nCond);
            end
            
            for iC = 1:nCond
                if sum(nT(:,iC))==0  % if no trials for iC condition, skip
                    continue;
                end
                
                lstPass = find(~isnan(squeeze(mean(yAvg(:,1,:,iC),1))) == 1);
                
                if iSubj==1 | iC>nStim
                    for iPass=1:length(lstPass)
                        for iHb=1:3
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,iHb,lstPass(iPass),iC) = interp1(tHRF, yAvg(:,iHb,lstPass(iPass),iC), tHRF(:));
                        end
                    end
                    nStim = iC;
                else
                    for iPass=1:length(lstPass)
                        for iHb=1:3
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,iHb,lstPass(iPass),iC) = grp1(:, iHb, lstPass(iPass), iC) + interp1(tHRF, yAvg(:,iHb,lstPass(iPass),iC), tHRF(:));
                        end
                    end
                end
                % keep count of number of conditions (i.e. number of times
                % the averages were added) to compute mean afterwards                
                subjCh(:,iC) = subjCh(:,iC) + 1; %#ok<*AGROW>
            end
            
            yAvg = [];
            if ~isempty(grp1)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        % compute group mean
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / subjCh(iCh,iC);
                        if iSubj == nSubj
                            % initialize data array for each HbO type and
                            % condition, per channel
                            yAvgOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
                            yAvgOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
                            yAvgOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);                            
                        end
                    end
                end
                if iSubj == nSubj                
                    yAvgOut(iBlk).AppendDataTimeSeries(yAvg);
                end
            end
            
        elseif strcmp(datatype{1}, 'HRF dOD')
            
            if iSubj==1
                grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
            end
            
            nCh  = size(yAvg,2);
            if isempty(subjCh)
                subjCh = zeros(nCh, nCond);
            end

            for iC = 1:nCond
                if sum(nT(:,iC))==0
                    continue;
                end
                
                for iWl = 1:2
                    % Calculate which channels to include and exclude from the group HRF avg,
                    % based on the subjects' standard error and store result in iCh
                    if iSubj==1 | iC>nStim
                        for iCh = 1:nCh
                            grp1(:,iCh,iC) = interp1(tHRF, yAvg(:,iCh,iC), tHRF(:));
                        end
                        nStim = iC;
                    else
                        for iCh = 1:size(yAvg,2)
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,iCh,iC) = grp1(:,iCh,iC) + interp1(tHRF, yAvg(:,iCh,iC), tHRF(:));
                        end
                    end
                    subjCh(:,iC) = subjCh(:,iC) + 1;
                end
            end
            
            yAvg = [];
            if ~isempty(grp1)
                for iC = 1:size(grp1,3)
                    for iCh = 1:size(grp1,2)
                        yAvg(:,:,iC) = grp1(:,:,iC) / subjCh(iCh,iC);
                        if iSubj == nSubj
                            yAvgOut(iBlk).AddChannelDod(ml(iCh,1), ml(iCh,2), ml(iCh,4), iC);
                        end
                    end
                end
                if iSubj == nSubj % check if the computation has been done over all subjects
                    % save the average over subjects in output data array
                    yAvgOut(iBlk).AppendDataTimeSeries(yAvg);
                end
            end
            
        end
    end
    nTrials{iBlk} = nT;
end


if all(err<0)
    MessageBox('Warning: All subject input to hmrG_SubjAvg.m is empty.')
end

