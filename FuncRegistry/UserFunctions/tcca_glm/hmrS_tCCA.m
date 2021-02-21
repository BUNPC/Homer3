% SYNTAX:
% status = hmrS_tCCA(subjIdx, subjName)
%
% UI NAME:
% hmrS_tCCA
%
% DESCRIPTION:
%
% INPUT:
% subjName - the name of the subject in a group 
%
% OUTPUTS:
% status - error status
%
% USAGE OPTIONS:
% tCCA_filter: status = hmrS_tCCA(iSubj, name)
%
function status = hmrS_tCCA(subjIdx, subjName)

status = 0;

filenamePrefixNum = sprintf('tCCAfilter_%d', subjIdx);
filenamePrefixName = sprintf('tCCAfilter_%s', subjName);

files = dir(['./', filenamePrefixNum, '*']);
try
    for ii = 1:length(files)
        if files(ii).isdir
            continue
        end
        k = findstr(filenamePrefixNum, files(ii).name);
        suffix = files(ii).name(k+length(filenamePrefixNum):end);
        if ~exist(subjName, 'dir')
            movefile(files(ii).name, [filenamePrefixName, suffix]);
            continue;
        end
        movefile(files(ii).name, [subjName, '/', filenamePrefixName, suffix]);
    end
catch
    status = -1;
end


