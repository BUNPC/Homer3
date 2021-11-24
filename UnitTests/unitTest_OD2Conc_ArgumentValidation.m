% This script checks for expected errors given the argument validation
% functions
clear all; clc;
import matlab.unittest.constraints.IsEqualTo

% load test data file
fname = 'Example_RunFuncOffline/test.snirf';
data_nirs = {SnirfClass(fname)}; 
acquired = data_nirs{1};

% load expected data output
load('expected outputs/dhb_expected.mat') % dhb_expected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error checks
%--------------------------------------------------------------------------
testCase = matlab.unittest.TestCase.forInteractiveUse;

% wrong object trhows class exception
verifyError(testCase,@() hmrR_OD2Conc(acquired, acquired.probe, [1.0 1.0]), ...
    "Class:notCorrectClass")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired, [1.0 1.0]), ...
    "Class:notCorrectClass")

% check ppf mustBeNumeric
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, ['h' 1.0]), ...
    "MATLAB:validators:mustBeNumeric")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [true true]), ...
    "MATLAB:validators:mustBeNumeric")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [1 'h']), ...
    "MATLAB:validators:mustBeNumeric")

% check ppf mustBePositive
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [-1.0 -1.0]), ...
    "MATLAB:validators:mustBePositive")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [1.0 -1.0]), ...
    "MATLAB:validators:mustBePositive")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [-1.0 1.0]), ...
    "MATLAB:validators:mustBePositive")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [0 1.0]), ...
    "MATLAB:validators:mustBePositive")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [1.0 0]), ...
    "MATLAB:validators:mustBePositive")
verifyError(testCase,@() hmrR_OD2Conc(acquired.data, acquired.probe, [0 0]), ...
    "MATLAB:validators:mustBePositive")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expected output checks
%--------------------------------------------------------------------------
dhb_out = hmrR_OD2Conc(acquired.data, acquired.probe, [1.0 1.0]);
testCase.verifyThat(dhb_out, IsEqualTo(dhb_expected))

