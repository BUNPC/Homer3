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
if isempty(dataTree.group)
    return;
end
if isempty(dataTree.group.subjs)
    return;
end
if isempty(dataTree.group.subjs(isubj).runs)
    return;
end
if isempty(dataTree.group.subjs(isubj).runs(irun).procStream.input.fcalls)
    return;
end
       
iFcall = dataTree.group(igroup).subjs(isubj).runs(irun).procStream.input.GetFuncCallIdx(funcName);
if isempty(iFcall)
    return;
end
paramIdx = dataTree.group(igroup).subjs(isubj).runs(irun).procStream.input.fcalls(iFcall).GetParamIdx(paramName);
if isempty(paramIdx)
    return;
end
val = dataTree.group(igroup).subjs(isubj).runs(irun).procStream.input.fcalls(iFcall).paramIn(paramIdx).value;

