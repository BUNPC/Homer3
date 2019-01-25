function calcProcStream()

dataTree = LoadDataTree('.nirs');
dataTree.group.Calc();
dataTree.group.Save();
