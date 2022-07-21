% SYNTAX:
% [yAvgStd, yAvgStdErr] = hmrS_SessAvgStd2(yAvgStdRuns, nTrialsRuns)
%
% UI NAME:
% Run_Average_Standard_Deviation_and_Error
%
% DESCRIPTION:
% Calculates a weighted avearge of HRF standard deviation and standard error across runs.trials within a subject.
%
% INPUTS:
% yAvgStdRuns:
% nTrialsRuns:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across runs.trials
% yAvgStdErrOut: the standard error across runs.trials
%
% USAGE OPTIONS:
% Run_Average_Standard_Deviation_on_Concentration_Data:  [dcAvgStd, dcAvgStdErr]  = hmrS_SessAvgStd2(dcAvgStdSess, nTrialsSess)
%

function [yAvgStdOut, yAvgStdErrOut] = hmrS_SessAvgStd2(yAvgStdSess, nTrialsSess)

yAvgStdOut = DataClass();
yAvgStdErrOut = DataClass();

if isempty(yAvgStdSess)
    return
end
if isempty(nTrialsSess)
    return
end

N = 0;
var = 0;
nDataBlks = length(yAvgStdSess{1});

% find max nCond
for i = 1:size(nTrialsSess, 2)
    if isempty(nTrialsSess{i})
        return;
    else
        niC(i) = size(nTrialsSess{i}{1},2);
    end
end
niC = max(niC);

for iBlk = 1:nDataBlks
    
    nTrials = zeros(1,niC);
    for iC = 1:niC
        for iSess = 1:length(nTrialsSess)
            if ~isempty(nTrialsSess{iSess}{iBlk})
                nTrials(iC) = nTrials(iC) + nTrialsSess{iSess}{1}(iC);
            end
        end
    end
    
    % get tHRF and ml from yAvgSess
    for iSess = 1:length(yAvgStdSess)
        tHRF    = yAvgStdSess{iSess}(iBlk).GetTime();
        ml    = yAvgStdSess{iSess}(iBlk).GetMeasListSrcDetPairs('reshape');
        if ~isempty(ml)
            break
        end
    end
    yAvgStdOut(iBlk).SetTime(tHRF);
    yAvgStdErrOut(iBlk).SetTime(tHRF);
    
    for iC = 1:niC % across conditions
        
        % get total number of trials per given condition
        for iSess = 1:length(yAvgStdSess)
            if ~isempty(nTrialsSess{iSess}{iBlk})
                N = N + nTrialsSess{iSess}{iBlk}(iC);
            end
        end
        
        %         if N ~= 0
        % get average of variance across runs weighted by number of trials within a run
        for iSess = 1:length(yAvgStdSess)
            if  ~isempty(nTrialsSess{iSess}{iBlk})
                if nTrialsSess{iSess}{iBlk}(iC) ~= 0
                    yAvgStd    = yAvgStdSess{iSess}(iBlk).GetDataTimeSeries('reshape');
                    if isempty(yAvgStd) ~= 1
                        var = var + (nTrialsSess{iSess}{iBlk}(iC)-1)/(N-1) * yAvgStd(:,:,:,iC).^2;
                    end
                end
            end
        end
        
        % get std and append
        yAvgStd_wa = sqrt(var);
        if yAvgStd_wa == 0
            yAvgStd_wa = zeros(length(tHRF), 3, size(ml,1));
            yAvgStdErr_wa = zeros(length(tHRF), 3, size(ml,1));
        end
        yAvgStdOut(iBlk).AppendDataTimeSeries(yAvgStd_wa);
        
        yAvgStdErr_wa = yAvgStd_wa/sqrt(nTrials(iC)-1);
        yAvgStdErrOut(iBlk).AppendDataTimeSeries(yAvgStdErr_wa);
        
        var = 0;
        N = 0;
        
        for iCh = 1:size(ml,1)
            yAvgStdOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
            
            yAvgStdErrOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdErrOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdErrOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
        end
        
    end
end

