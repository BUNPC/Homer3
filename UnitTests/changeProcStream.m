function [dataTree, procStreamConfigFile] = changeProcStream(datafmt, procStreamCfg, funcName, paramName, newval)
global procStreamStyle

dataTree = [];

% Set globals
if isempty(procStreamStyle)
    procStreamStyle = datafmt;
end

% Parse args
if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('procStreamCfg','var')
    procStreamCfg = 'processOpt_default_homer3';
end
if ~exist('funcName','var')
    funcName = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get dataTree, based on the requested file data format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if includes(procStreamStyle, 'snirf') && includes(datafmt,'snirf')
    procStreamConfigFile = [procStreamCfg, '_snirf.cfg'];
elseif includes(procStreamStyle, 'nirs')
    procStreamConfigFile = [procStreamCfg, '_nirs.cfg'];
    funcName = [funcName, '_Nirs'];
else
    procStreamConfigFile = [procStreamCfg, '_nirs.cfg'];
    funcName = [funcName, '_Nirs'];
end

if exist(['./', procStreamConfigFile], 'file')
    procStreamConfigFile = ['./', procStreamConfigFile];
elseif exist(['../', procStreamConfigFile], 'file')
    procStreamConfigFile = ['../', procStreamConfigFile];
else
    fprintf('Could not find proc stream config file %s ...\n', procStreamConfigFile);
    return;
end

dataTree = LoadDataTree(pwd, datafmt, procStreamConfigFile);
if isempty(dataTree)
    return;
end
if dataTree.IsEmpty()
    return;
end
if nargin<3    % If only 1 arg, we're just getting dataTree but not changing it in any way
    return;
end
if isempty(funcName)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Otherwise if more than one agument, we're not just retrieving datatree but
% also changing the proc stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
igroup = 1;
isubj = 1;
isess = 1;
irun = 1;

iFcall = dataTree.groups(igroup).subjs(isubj).sess(isess).runs(irun).procStream.GetFuncCallIdx(funcName);
if isempty(iFcall)
    return;
end
paramIdx = dataTree.groups(igroup).subjs(isubj).sess(isess).runs(irun).procStream.fcalls(iFcall).GetParamIdx(paramName);
if isempty(paramIdx)
    return;
end
oldval = dataTree.groups(igroup).subjs(isubj).sess(isess).runs(irun).procStream.fcalls(iFcall).GetParamVal(paramName);
if ~exist('newval','var') || isempty(newval)
    newval = oldval;
end

for iSubj = 1:length(dataTree.groups(igroup).subjs)
    for iSess = 1:length(dataTree.groups(igroup).subjs(iSubj).sess)
        for iRun = 1:length(dataTree.groups(igroup).subjs(iSubj).sess(iSess).runs)
            dataTree.groups(igroup).subjs(iSubj).sess(iSess).runs(iRun).procStream.EditParam(iFcall, paramIdx, newval);
        end
    end
end

