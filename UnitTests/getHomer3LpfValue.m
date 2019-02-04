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
lpf = dataTree.group.subjs(isubj).runs(irun).procStream.input.fcalls(3).paramIn(2).value;
