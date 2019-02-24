function dataTree = calcProcStreamChanged(datafmt, newval)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('newval','var') || isempty(newval)
    newval = 1.6;
end
config = ConfigFileClass([fileparts(which('Homer3')), '/Homer3.cfg']);
dataTree = LoadDataTree(datafmt, config.params.ProcStreamFile);
iSubj = 2;
iRun = 2;
iFcall = dataTree.group.subjs(iSubj).runs(iRun).procStream.input.GetFuncCallIdx('hmrR_BandpassFilt_Nirs');
dataTree.group.subjs(iSubj).runs(iRun).procStream.EditParam(iFcall, 2, newval);
dataTree.group.Calc();
dataTree.group.Save();

