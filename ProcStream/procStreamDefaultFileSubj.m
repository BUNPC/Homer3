function [contents, str] = procStreamDefaultFileSubj(funcRun)

% Choose default procStream group section based on the run procStream
% output; if it's output ia dodAvg, choose the dodAvg default, otherwise
% choose dcAvg. 
if ~exist('funcRun','var') | isempty(funcRun)
    funcRun(1).argOut = '';
end

datatype = 'dcAvg';
for ii=1:length(funcRun)
    if ~isempty(strfind(funcRun(ii).argOut, 'dodAvg'))
        datatype = 'dodAvg';
        break;
    end
end

contents_dcAvg = {...
    '%% subj\n', ...
    '@ hmrS_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials] (dcAvgRuns,dcAvgStdRuns,dcSum2Runs,tHRFRuns,SDRuns,nTrialsRuns,CondName2Run\n', ...
    '\n\n', ...
    };

contents_dodAvg = {...
    '%% subj\n', ...
    '@ hmrS_BlockAvg [dodAvg,dodAvgStd,tHRF,nTrials] (dodAvgRuns,dodAvgStdRuns,dodSum2Runs,tHRFRuns,SDRuns,nTrialsRuns,CondName2Run\n', ...
    '\n\n', ...
    };

if strcmp(datatype, 'dcAvg')
    contents = contents_dcAvg;
else
    contents = contents_dodAvg;
end

str = cell2str(contents);

