function status = unitTest2(newval)

if ~exist('newval','var')
    newval = [];
end
rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/UnitTests/Example9_SessRuns']);
status = 0;
resetGroupFolder();
calcProcStreamChanged(newval);
compareOutputs1();

cd(currpath);

