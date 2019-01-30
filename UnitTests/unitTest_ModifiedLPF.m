function status = unitTest_ModifiedLPF(datafmt, newval)

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
isubj=2;
irun=2;
lpf_homer2 = getHomer2LpfValue(isubj, irun);
lpf_homer3 = getHomer3LpfValue(dataTree, isubj, irun);

% Homer2 used .5 for high pass filter to generate groupResults_homer2.mat, 
% therefore if Homer3 LPF ~= .5 we expect the data not to match and compareOutputs1
% to return non-zero status. 
if status==0 && (lpf_homer2 == lpf_homer3)
    fprintf('unitTest_ModifiedLPF(''%s'', %0.1f): TEST SUCCEEDED - Homer3 output matches Homer2 for same LPF values {lpf_homer2=%0.3f, lpf_homer3=%0.3f} as expected.\n', datafmt, newval, lpf_homer2, lpf_homer3);
elseif status~=0 && (lpf_homer2 ~= lpf_homer3)
    fprintf('unitTest_ModifiedLPF(''%s'', %0.1f): TEST SUCCEEDED - Homer3 output does NOT match Homer2 for different LPF values {lpf_homer2=%0.3f, lpf_homer3=%0.3f}, as expected.\n', datafmt, newval, lpf_homer2, lpf_homer3);
elseif status==0 && (lpf_homer2 ~= lpf_homer3)
    fprintf('unitTest_ModifiedLPF(''%s'', %0.1f): TEST FAILED - Homer3 output matches Homer2 for different LPF values {lpf_homer2=%0.3f, lpf_homer3=%0.3f}.\n', datafmt, newval, lpf_homer2, lpf_homer3);
elseif status~=0 && (lpf_homer2 == lpf_homer3)
    fprintf('unitTest_ModifiedLPF(''%s'', %0.1f): TEST FAILED - Homer3 does NOT match Homer2 for same LPF values {lpf_homer2=%0.3f, lpf_homer3=%0.3f}.\n', datafmt, newval, lpf_homer2, lpf_homer3);
end

% Unit test success status is the opposite of the compareOutputs1 status. 
if lpf_homer3~=.5
    status = ~status;
end

cd(currpath);

