function status = unitTest_DefaultProcStream(datafmt, dirname)
global testidx
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

rootpath = fileparts(which('Homer3.m'));
currpath = pwd;

cd([rootpath, '/', dirname]);
resetGroupFolder();
calcProcStream(datafmt);

groupFiles_h2 = mydir('./groupResults_homer2_*.mat');
for iG=1:length(groupFiles_h2)   
    group_h2 = load(groupFiles_h2(iG).name);
    status = compareOutputs1(group_h2);
    if status==0
        break;
    end
end

if status==0
    fprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): TEST PASSED - Homer3 output matches %s.\n', ...
            testidx, datafmt, dirname,  [groupFiles_h2(iG).pathfull, '/', groupFiles_h2(iG).name]);
elseif status>0
    fprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): TEST FAILED - Homer3 output does NOT match ANY Homer2 groupResults.\n', testidx, datafmt, dirname);
elseif status<0
    fprintf('#%d - unitTest_DefaultProcStream(''%s'', ''%s''): TEST FAILED - Homer3 did NOT generate ANY output\n', testidx, datafmt, dirname);
end

cd(currpath);

