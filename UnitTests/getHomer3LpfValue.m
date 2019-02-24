function lpf = getHomer3LpfValue(dataTree, isubj, irun)
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
iFcall = dataTree.group.subjs(isubj).runs(irun).procStream.input.GetFuncCallIdx('hmrR_BandpassFilt_Nirs');
lpf = dataTree.group.subjs(isubj).runs(irun).procStream.input.fcalls(iFcall).paramIn(2).value;
