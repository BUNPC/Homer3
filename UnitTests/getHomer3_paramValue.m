function val = getHomer3_paramValue(funcName, paramName, dataTree, igroup, isubj, irun)
global procStreamStyle

if ~exist('igroup','var')
    igroup = 1;
end
if ~exist('isubj','var')
    isubj = 1;
end
if ~exist('irun','var') || isempty(newval)
    irun = 1;
end

if includes(procStreamStyle,'nirs')
    funcName = [funcName, '_Nirs'];
end

val = [];
if isempty(dataTree)
    return;
end
if isempty(dataTree.groups)
    return;
end
if isempty(dataTree.groups(igroup).subjs)
    return;
end
if isempty(dataTree.groups(igroup).subjs(isubj).runs)
    return;
end
if isempty(dataTree.groups(igroup).subjs(isubj).runs(irun).procStream.fcalls)
    return;
end
       
iFcall = dataTree.groups(igroup).subjs(isubj).runs(irun).procStream.GetFuncCallIdx(funcName);
if isempty(iFcall)
    return;
end
paramIdx = dataTree.groups(igroup).subjs(isubj).runs(irun).procStream.fcalls(iFcall).GetParamIdx(paramName);
if isempty(paramIdx)
    return;
end
val = dataTree.groups(igroup).subjs(isubj).runs(irun).procStream.fcalls(iFcall).paramIn(paramIdx).value;

