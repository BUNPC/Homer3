% SYNTAX:
% status = hmrE_tCCA(sessIdx, sessName, derivedFolder)
%
% UI NAME:
% hmrE_tCCA
%
% DESCRIPTION:
%
% INPUT:
% sessIdx       - 
% sessName      - the name of the session in a subject
% derivedFolder - 
%
% OUTPUTS:
% status - error status
%
% USAGE OPTIONS:
% tCCA_filter: status = hmrE_tCCA(iSess, name, outputDirname)
%
function status = hmrE_tCCA(sessIdx, sessName, derivedFolder)

status = 0;

filenamePrefixNum = sprintf('tCCAfilter_%d', sessIdx);
filenamePrefixName = sprintf('tCCAfilter_%s', sessName);

files = dir(['./', filenamePrefixNum, '*']);
try
    for ii = 1:length(files)
        if files(ii).isdir
            continue
        end
        k = findstr(filenamePrefixNum, files(ii).name);
        suffix = files(ii).name(k+length(filenamePrefixNum):end);
        if ~exist(sessName, 'dir')
            movefile(files(ii).name, [filenamePrefixName, suffix]);
            continue;
        end
        movefile(files(ii).name, [derivedFolder, '/', sessName, '/', filenamePrefixName, suffix]);
    end
catch
    status = -1;
end


