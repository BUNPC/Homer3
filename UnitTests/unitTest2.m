function status = unitTest2(datafmt, newval)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('newval','var')
    newval = [];
end

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/UnitTests/Example9_SessRuns']);
resetGroupFolder();
dataTree = calcProcStreamChanged(datafmt, newval);
status = compareOutputs1();

% Homer2 used .5 for high pass filter, therefore if Homer3 does not use this
% value for hpf we expect the comparison to fail and a status NOT equal
% zero. Therefore the unit test status is the opposite of the
% compareOutputs1 status. 
if getHomer3LpfValue(dataTree)~=.5
    status = ~status;
end

if status==0
    fprintf('unitTest2(''%s'', %0.1f): Homer3 output matches expected output for this data\n', datafmt, getHomer3LpfValue(dataTree));
else
    fprintf('unitTest2(''%s'', %0.1f): Homer3 output does NOT match expected output for this data\n', datafmt, getHomer3LpfValue(dataTree));
end

cd(currpath);

