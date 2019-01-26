function lpf = getHomer3LpfValue(dataTree)

lpf = dataTree.group.subjs(2).runs(2).procStream.input.func(3).paramVal{2};
