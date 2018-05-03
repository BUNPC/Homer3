% When ever you change this function, then it is necessary to run
% procStreamGenHelp() from the matlab command line

function callReg = procStreamRegSubj()

callReg = ...
{...
'@ hmrBlockAvgSubj [dcAvg,dcAvgStd,tHRF,nTrials] (dcAvgRuns,dcAvgStdRuns,tHRFRuns,SDRuns,nTrialsRuns,CondSubj2Run' ...
};

