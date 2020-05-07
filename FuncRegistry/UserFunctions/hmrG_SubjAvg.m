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
% yAvgSubjs:
% nTrialsSubjs:
%
% OUTPUTS:
% yAvgOut: the averaged results
% nTrials: 
%
% USAGE OPTIONS:
% Subj_Average_on_Concentration_Data: [dcAvg, nTrials] = hmrG_SubjAvg(dcAvgSubjs, nTrialsSubjs)
% Subj_Average_on_Delta_OD_Data:      [dodAvg, nTrials] = hmrG_SubjAvg(dodAvgSubjs, nTrialsSubjs)
%
%
function [yAvgOut, nTrials] = hmrG_SubjAvg(yAvgSubjs, nTrialsSubjs)

yAvgOut = DataClass().empty();
nTrials = [];

nSubj = length(yAvgSubjs);

for iBlk = 1:length(yAvgSubjs{1})
    
    subjCh = [];
    nStim = 0;
    grp1 = [];
    nT = [];    
    
    for iSubj = 1:nSubj
        
        yAvgOut(iBlk) = DataClass();        
        
        yAvg      = yAvgSubjs{iSubj}(iBlk).GetDataTimeSeries('reshape');
        tHRF      = yAvgSubjs{iSubj}(iBlk).GetTime();
        nT        = nTrialsSubjs{iSubj}{iBlk};
        datatype  = yAvgSubjs{iSubj}(iBlk).GetDataTypeLabel();
        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))
            ml    = yAvgSubjs{iSubj}(iBlk).GetMeasListSrcDetPairs();
        elseif strcmp(datatype{1}, 'HRF dOD')
            ml    = yAvgSubjs{iSubj}(iBlk).GetMeasList();
        end
        
        if isempty(yAvg)
            continue;
        end
        
        nCond = size(nT,2);
        yAvgOut(iBlk).SetTime(tHRF);
        
        if strncmp(datatype{1}, 'HRF Hb', length('HRF Hb'))            
            if iSubj==1
                grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
            end
            
            nCh  = size(yAvg,3);
            if isempty(subjCh)
                subjCh = zeros(nCh, nCond);
            end
            
            for iC = 1:nCond
                if sum(nT(:,iC))==0
                    continue;
                end
                
                if iSubj==1 | iC>nStim
                    for iCh = 1:nCh
                        for iHb=1:3
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,iHb,iCh,iC) = interp1(tHRF, yAvg(:,iHb,iCh,iC), tHRF(:));
                        end
                    end
                    nStim = iC;
                else
                    for iCh = 1:size(yAvg,3)
                        for iHb=1:3
                            % Make sure 3rd arg to interp1 is column vector to guarauntee interp1 output is column vector
                            % which matches grp1 dimensions when adding the two.
                            grp1(:,iHb,iCh,iC) = grp1(:, iHb, iCh, iC) + interp1(tHRF, yAvg(:,iHb,iCh,iC), tHRF(:));
                        end
                    end
                end
                subjCh(:,iC) = subjCh(:,iC) + 1; %#ok<*AGROW>
            end
            
            yAvg = [];
            if ~isempty(grp1)
                for iC = 1:size(grp1,4)
                    for iCh = 1:size(grp1,3)
                        yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / subjCh(iCh,iC);
                        if iSubj == nSubj
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
                if iSubj == nSubj
                    yAvgOut(iBlk).AppendDataTimeSeries(yAvg);
                end
            end
            
        end
    end
    nTrials{iBlk} = nT;
end
