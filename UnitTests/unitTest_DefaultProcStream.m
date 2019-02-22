function status = unitTest_DefaultProcStream(datafmt, dirname)

status = -1;
if ~exist('datafmt','var')
    datafmt = 'nirs';
end
if ~exist('dirname','var')
    return;
end

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/', dirname]);
resetGroupFolder();
calcProcStream(datafmt);
status = compareOutputs1();

if status==0
    fprintf('unitTest_DefaultProcStream(''%s''): TEST PASSED - Homer3 output matches Homer2 for this data as expected.\n', datafmt);
elseif status>0
    fprintf('unitTest_DefaultProcStream(''%s''): TEST FAILED - Homer3 output does NOT match Homer2 for this data.\n', datafmt);
elseif status<0
    fprintf('unitTest_DefaultProcStream(''%s''): TEST FAILED - Homer3 did not generate any output\n', datafmt);
end

cd(currpath);

