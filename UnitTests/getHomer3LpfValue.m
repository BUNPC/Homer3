function lpf = getHomer3LpfValue(dataTree, igroup, isubj, irun)
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

if strcmp(procStreamStyle,'snirf')
    funcToChange = 'hmrR_BandpassFilt';
    paramIdx = 2;
else
    funcToChange = 'hmrR_BandpassFilt_Nirs';
    paramIdx = 2;
end

lpf = [];
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

iFcall = dataTree.group(igroup).subjs(isubj).runs(irun).procStream.input.GetFuncCallIdx(funcToChange);
if isempty(iFcall)
    return;
end
lpf = dataTree.group(igroup).subjs(isubj).runs(irun).procStream.input.fcalls(iFcall).paramIn(paramIdx).value;
