function [contents, str] = procStreamDefaultFileGroup(funcRun)

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
    '%% group\n', ...
    '@ hmrG_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,grpAvgPass] (dcAvgSubjs,dcAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondName2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
    '\n\n', ...
    };

contents_dodAvg = {...
    '%% group\n', ...
    '@ hmrG_BlockAvg [dodAvg,dodAvgStd,tHRF,nTrials,grpAvgPass] (dodAvgSubjs,dodAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondName2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
    '\n\n', ...
    };

if strcmp(datatype, 'dcAvg')
    contents = contents_dcAvg;
else
    contents = contents_dodAvg;
end

str = cell2str(contents);

