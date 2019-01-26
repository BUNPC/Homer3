function dataTree = calcProcStreamChanged(datafmt, newval)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('newval','var') || isempty(newval)
    newval = 1.6;
end

dataTree = LoadDataTree(datafmt);
dataTree.group.subjs(2).runs(2).procStream.EditParam(3, 2, newval);
dataTree.group.Calc();
dataTree.group.Save();

