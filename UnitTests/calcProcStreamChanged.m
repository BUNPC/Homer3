function dataTree = calcProcStreamChanged(datafmt, newval)
global procStreamStyle

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('newval','var') || isempty(newval)
    newval = 1.6;
end
if isempty(procStreamStyle)
    procStreamStyle = 'snirf';
end

procStreamConfigFile = 'processOpt_default_homer3_nirs.cfg';
funcToChange = 'hmrR_BandpassFilt_Nirs';
paramIdx = 2;
if strcmp(procStreamStyle,'snirf') && includes(datafmt,'snirf')
    procStreamConfigFile = 'processOpt_default_homer3_snirf.cfg';
    funcToChange = 'hmrR_BandpassFilt';
    paramIdx = 2;
end

dataTree = LoadDataTree(datafmt, procStreamConfigFile);
if isempty(dataTree)
    return;
end
if dataTree.IsEmpty()
    return;
end
iFcall = dataTree.group.subjs(1).runs(1).procStream.input.GetFuncCallIdx(funcToChange);
for iSubj=1:length(dataTree.group.subjs)
    for iRun=1:length(dataTree.group.subjs(iSubj).runs)
        dataTree.group.subjs(iSubj).runs(iRun).procStream.EditParam(iFcall, paramIdx, newval);
    end
end
dataTree.group.Calc();
dataTree.group.Save();

