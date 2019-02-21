function calcProcStream(datafmt)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end

config = ConfigFileClass([fileparts(which('Homer3')), '/Homer3.cfg']);
dataTree = LoadDataTree(datafmt, config.params.ProcStreamFile);
dataTree.group.Calc();
dataTree.group.Save();
