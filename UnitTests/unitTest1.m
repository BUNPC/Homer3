function status = unitTest1()

rootpath = fileparts(which('homer3.m'));

currpath = pwd;
cd([rootpath, '/UnitTests/Example9_SessRuns']);
status = 0;
resetGroupFolder();
calcProcStream();

% Load results from homer2 and homer3 
group_h2 = load('./groupResults_homer2.mat');
group_h3 = load('./groupResults.mat');

% Compare results: Here are the tests we must pass to get clean bill of health
if ~isequaln(group_h2.group.procResult.dcAvg(:), group_h3.group.procResult.dcAvg(:))
    status=1;
end
if ~isequaln(group_h2.group.procResult.dodAvg(:), group_h3.group.procResult.dodAvg(:))
    status=1;
end

if status==0
    fprintf('Output matches homer2 output for this data\n');
else
    fprintf('Output does NOT match homer2 output for this data\n');    
end

cd(currpath);

