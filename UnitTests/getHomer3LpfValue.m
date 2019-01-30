function lpf = getHomer3LpfValue(dataTree, isubj, irun)

lpf = dataTree.group.subjs(isubj).runs(irun).procStream.input.func(3).paramVal{2};
