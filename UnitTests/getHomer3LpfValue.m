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
if isempty(dataTree.group.subjs(isubj).runs(irun).procStream.input.func)
    return;
end
lpf = dataTree.group.subjs(isubj).runs(irun).procStream.input.func(3).paramVal{2};
