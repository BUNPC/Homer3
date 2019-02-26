function dataTree = calcProcStreamChanged(datafmt, newval)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('newval','var') || isempty(newval)
    newval = 1.6;
end
config = ConfigFileClass([fileparts(which('Homer3')), '/Homer3.cfg']);
dataTree = LoadDataTree(datafmt, config.params.ProcStreamFile);
iFcall = dataTree.group.subjs(1).runs(1).procStream.input.GetFuncCallIdx('hmrR_BandpassFilt_Nirs');
for iSubj=1:length(dataTree.group.subjs)
    for iRun=1:length(dataTree.group.subjs(iSubj).runs)
        dataTree.group.subjs(iSubj).runs(iRun).procStream.EditParam(iFcall, 2, newval);
    end
end
dataTree.group.Calc();
dataTree.group.Save();

