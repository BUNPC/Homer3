function status = unitTest1(datafmt)

if ~exist('datafmt','var')
    datafmt = 'nirs';
end

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/UnitTests/Example9_SessRuns']);
resetGroupFolder();
calcProcStream(datafmt);
status = compareOutputs1();

if status==0
    fprintf('unitTest1(''%s''): Homer3 output matches expected output for this data\n', datafmt);
else
    fprintf('unitTest1(''%s''): Homer3 output does NOT match expected output for this data\n', datafmt);
end


cd(currpath);

