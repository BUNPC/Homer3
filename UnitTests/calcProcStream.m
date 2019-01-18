function calcProcStream()

files = NirsFilesClass().files;
dataTree = DataTreeClass(files);
dataTree.group.Calc();
dataTree.group.Save();
