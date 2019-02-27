function dataTree = calcProcStream(datafmt)
global procStreamStyle

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if isempty(procStreamStyle)
    procStreamStyle = 'snirf';
end

if strcmp(procStreamStyle,'snirf') && includes(datafmt,'snirf')
    procStreamConfigFile = 'processOpt_default_homer3_snirf.cfg';
elseif strcmp(procStreamStyle,'nirs')
    procStreamConfigFile = 'processOpt_default_homer3_nirs.cfg';
end

dataTree = LoadDataTree(datafmt, procStreamConfigFile);
dataTree.group.Calc();
dataTree.group.Save();
