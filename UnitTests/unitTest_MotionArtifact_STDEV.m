function status = unitTest_MotionArtifact_STDEV(datafmt, dirname, newval)
global procStreamStyle
global testidx
global logger

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inititialize and error check input argument 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('dirname','var')
    return;
end
if ~exist('newval','var')
    newval = [];
end
logger = InitLogger(logger, 'unitTest_MotionArtifact_STDEV');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up logger and other administrative paramaters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write('################################################################');
logger.Write(sprintf('Running test #%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f)\n', testidx, datafmt, dirname, newval));
fprintf('\n');

[~, currpath] = findRootFolder(dirname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change processing stream param values to newval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[dataTree, procStreamConfigFile] = changeProcStream(datafmt, 'processOpt_motionArtifact_homer3', 'hmrR_MotionArtifact', 'STDEVthresh', newval);
if isempty(dataTree)
    status = exitEarly(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): SKIPPING - This test does not apply to %s.\n', ...
                               testidx, datafmt, dirname, newval, dirname), logger);
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Homer3 output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write(sprintf('Loaded processing stream from %s\n', procStreamConfigFile));
generateOutput(dataTree);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare Homer3 output to the available Homer2 output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupResults_h2 = mydir('./groupResults_homer2_*.mat');
s = zeros(length(groupResults_h2), 2);
for iG=1:length(groupResults_h2)
    group_h2 = load(groupResults_h2(iG).name);
    [~, groupResults_h2(iG).rootdir] = fileparts(groupResults_h2(iG).rootdir);
    s(iG,1) = compareDcAvg(group_h2, dataTree, 'dcAvg');
    s(iG,2) = compareProcStreams(dataTree, groupResults_h2(iG));
    
    msgs = MatchMessages(sum(s(iG,:)));
    logger.Write(sprintf('Comparing output to %s  ==>  Outputs: %s,   Proc Streams: %s\n', groupResults_h2(iG).name, msgs{1}, msgs{2}));
end
iMatch = find(s(:,1)==0 & s(:,2)==0);
if ~isempty(iMatch)
    status=0;
else
    status=1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Report results of the comparison
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write(sprintf('\n'));
if status==0
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST PASSED - Homer3 output matches %s.\n', ...
             testidx, datafmt, dirname, newval, [groupResults_h2(iMatch).rootdir, '/', groupResults_h2(iMatch).name]));
else
    logger.Write(sprintf('#%d - unitTest_MotionArtifact_STDEV(''%s'', ''%s'', %0.1f): TEST FAILED - Homer3 output does NOT match ANY Homer2 groupResults.\n', testidx, datafmt, dirname, newval));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up before exiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write('\n');
logger.Close('unitTest_MotionArtifact_STDEV');

dataTree.ResetAllGroups();

cd(currpath);

