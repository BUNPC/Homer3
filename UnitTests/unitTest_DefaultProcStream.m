function status = unitTest_DefaultProcStream(datafmt)

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
    fprintf('unitTest_DefaultProcStream(''%s''): TEST SUCCEEDED - Homer3 output matches Homer2 for this data as expected.\n', datafmt);
else
    fprintf('unitTest_DefaultProcStream(''%s''): TEST FAILED - Homer3 output does NOT match Homer2 for this data.\n', datafmt);
end

cd(currpath);

