function calcProcStream(datafmt)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end

dataTree = LoadDataTree(datafmt);
dataTree.group.Calc();
dataTree.group.Save();
