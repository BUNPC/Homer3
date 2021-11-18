% This script checks for expected errors given the argument validation
% functions

% load test data file
fname = 'Example_RunFuncOffline/test.snirf';
data_nirs = {SnirfClass(fname)}; 
acquired = data_nirs{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error checks
%--------------------------------------------------------------------------
testCase = matlab.unittest.TestCase.forInteractiveUse;

% wrong object trhows class exception
verifyError(testCase,@() hmrR_Intensity2OD(acquired), ...
    "Class:notCorrectClass")

