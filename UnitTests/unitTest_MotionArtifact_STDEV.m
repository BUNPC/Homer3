function status = unitTest_MotionArtifact_STDEV(datafmt, dirname, newval, logger)
global procStreamStyle
global testidx

if isempty(procStreamStyle)
    procStreamStyle = datafmt;
end
if includes(procStreamStyle,'snirf')
    datafmt = 'snirf';
end
if isempty(testidx)
    testidx=0;
end
testidx=testidx+1;

status = -1;
if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('dirname','var')
    return;
end
if ~exist('newval','var')
    newval = [];
end
if ~exist('logger','var') || isempty(logger)
    logger = LogClass();
end

logger.Write('######################################\n');
logger.Write(sprintf('Running test #%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f)\n', testidx, datafmt, dirname, newval));
fprintf('\n');

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/', dirname]);
resetGroupFolder('', 'registry_keep');

[dataTree, procStreamConfigFile] = changeProcStream(datafmt, 'processOpt_motionArtifact_homer3', 'hmrR_MotionArtifact', 'STDEVthresh', newval);
if isempty(dataTree)
    status = exitEarly(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): SKIPPING - This test does not apply to %s.\n', ...
                               testidx, datafmt, dirname, newval, dirname), logger);
    return;
end
logger.Write(sprintf('Loaded processing stream from %s\n', procStreamConfigFile));
dataTree.group.Calc();
dataTree.group.Save();

groupFiles_h2 = mydir('./groupResults_homer2_*.mat');
for iG=1:length(groupFiles_h2)   
    group_h2 = load(groupFiles_h2(iG).name);
    [~, groupFiles_h2(iG).pathfull] = fileparts(groupFiles_h2(iG).pathfull);
    s(1) = compareDcAvg(group_h2, 'dcAvg');
    % s(2) = compareDcAvg(group_h2, 'dcAvgStd');
    status = ~all(s==0);
    if status==0
        break;
    end
end

stdevs = getHomer2_paramValue('hmrMotionArtifact','STDEVthresh', groupFiles_h2);
stdev  = getHomer3_paramValue('hmrR_MotionArtifact','STDEVthresh', dataTree);

amps = getHomer2_paramValue('hmrMotionArtifact','AMPthresh', groupFiles_h2);
amp  = getHomer3_paramValue('hmrR_MotionArtifact','AMPthresh', dataTree);

if status==0 & (~isempty(stdevs{iG}) & stdevs{iG}==stdev) & (~isempty(amps{iG}) & amps{iG}==amp)
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST PASSED - Homer3 output matches %s.\n', ...
             testidx, datafmt, dirname, newval, [groupFiles_h2(iG).pathfull, '/', groupFiles_h2(iG).name]));
elseif status==0 & ~isempty(stdevs{iG}) & stdevs{iG}~=stdev
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST FAILED - Homer3 output matches %s which has a different stdev value {%0.2f ~= %0.2f}.\n', ...
             testidx, datafmt, dirname, newval, [groupFiles_h2(iG).pathfull, '/', groupFiles_h2(iG).name], stdevs{iG}, stdev));
elseif status==0 & ~isempty(stdevs{iG}) & amps{iG}~=amp
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST FAILED - Homer3 output matches %s which has a different amp value {%0.2f ~= %0.2f}.\n', ...
             testidx, datafmt, dirname, newval, [groupFiles_h2(iG).pathfull, '/', groupFiles_h2(iG).name], amps{iG}, amp));
elseif status>0
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST FAILED - Homer3 output does NOT match ANY Homer2 groupResults.\n', testidx, datafmt, dirname, newval));
elseif status<0
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST FAILED - Homer3 did not generate any output\n', testidx, datafmt, dirname, newval));
end


logger.Write('\n');
if strcmp(logger.GetFilename(), 'History')
    logger.Close();
end

cd(currpath);

