function [contents, str] = procStreamDefaultFileGroup(procFuncRun)

% Choose default procStream group section based on the run procStream
% output; if it's output ia dodAvg, choose the dodAvg default, otherwise
% choose dcAvg. 
if ~exist('procFuncRun','var') | isempty(procFuncRun)
    procFuncRun(1).funcArgOut = '';
end

datatype = 'dcAvg';
for ii=1:length(procFuncRun)
    if ~isempty(strfind(procFuncRun(ii).funcArgOut, 'dodAvg'))
        datatype = 'dodAvg';
        break;
    end        
end

contents_dcAvg = {...
    '%% group\n', ...
    '@ hmrBlockAvgGroup [dcAvg,dcAvgStd,tHRF,nTrials,grpAvgPass] (dcAvgSubjs,dcAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondGroup2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
    '\n\n', ...
    };

contents_dodAvg = {...
    '%% group\n', ...
    '@ hmrBlockAvgGroup [dodAvg,dodAvgStd,tHRF,nTrials,grpAvgPass] (dodAvgSubjs,dodAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondGroup2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
    '\n\n', ...
    };

if strcmp(datatype, 'dcAvg')
    contents = contents_dcAvg;
else
    contents = contents_dodAvg;
end

str = cell2str(contents);

