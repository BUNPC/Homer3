% This script checks for expected errors given the argument validation
% functions
clear all; clc;
import matlab.unittest.constraints.IsEqualTo

% load test data file
fname = 'Example_RunFuncOffline/test.snirf';
data_nirs = {SnirfClass(fname)}; 
acquired = data_nirs{1};

% load expected data output 
load('expected outputs/dod_expected.mat') % dod_expected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error checks
%--------------------------------------------------------------------------
testCase = matlab.unittest.TestCase.forInteractiveUse;

% wrong object trhows class exception
verifyError(testCase,@() hmrR_Intensity2OD(acquired), ...
    "Class:notCorrectClass")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expected output checks
%--------------------------------------------------------------------------
dod_out = hmrR_Intensity2OD(acquired.data);
testCase.verifyThat(dod_out, IsEqualTo(dod_expected))

