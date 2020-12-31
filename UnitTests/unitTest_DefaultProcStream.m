function status = unitTest_DefaultProcStream(datafmt, dirname)
global procStreamStyle
global testidx
global logger

if isempty(procStreamStyle)
    procStreamStyle = datafmt;
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
logger = InitLogger(logger, 'unitTest_DefaultProcStream');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up logger and other administrative paramaters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write('######################################\n');
logger.Write(sprintf('Running test #%d - unitTest_DefaultProcStream(''%s'', ''%s'')\n', testidx, datafmt, dirname));
fprintf('\n');

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/', dirname]);
resetGroupFolder('', 'keep_registry:nodatatree');

% No new value argumetn means we're not changing processing stream, just retrieving it
[dataTree, procStreamConfigFile] = changeProcStream(datafmt, 'processOpt_default_homer3');
if isempty(dataTree)
    status = exitEarly(sprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): SKIPPING - This test does not apply to %s.\n', ...
                               testidx, datafmt, dirname, dirname), logger);
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Homer3 output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write(sprintf('Loaded processing stream from %s\n', procStreamConfigFile));
if dataTree.IsEmpty()
    return
end
dataTree.groups(1).Calc();
dataTree.groups(1).Save();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare Homer3 output to the available Homer2 output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupFiles_h2 = mydir('./groupResults_homer2_*.mat');
s = zeros(length(groupFiles_h2), 2);
for iG=1:length(groupFiles_h2)
    group_h2 = load(groupFiles_h2(iG).name);
    [~, groupFiles_h2(iG).pathfull] = fileparts(groupFiles_h2(iG).pathfull);

    s(iG,1) = compareDcAvg(group_h2, 'dcAvg');
    s(iG,2) = compareProcStreams(dataTree, groupFiles_h2(iG));
    
    msgs = MatchMessages(sum(s(iG,:)));
    logger.Write(sprintf('Comparing output to %s  ==>  Outputs: %s,   Proc Streams: %s\n', groupFiles_h2(iG).name, msgs{1}, msgs{2}));
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
    logger.Write(sprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): TEST PASSED - Homer3 output matches %s.\n', ...
             testidx, datafmt, dirname, [groupFiles_h2(iMatch).pathfull, '/', groupFiles_h2(iMatch).name]));
else
    logger.Write(sprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): TEST FAILED - Homer3 output does NOT match ANY Homer2 groupResults.\n', testidx, datafmt, dirname));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up before exiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write('\n');
logger.Close('unitTest_DefaultProcStream');

dataTree.groups(1).Reset();

cd(currpath);

