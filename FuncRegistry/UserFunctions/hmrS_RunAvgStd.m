% SYNTAX:
% yAvgStd = hmrS_RunAvgStd(yAvgRuns)
%
% UI NAME:
% Run_Average_Standard_Deviation
%
% DESCRIPTION:
% Calculate avearge HRF standard deviation of all runs for one subject. 
%
% INPUTS:
% yAvgRuns:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across runs
%
% USAGE OPTIONS:
% Run_Average_Standard_Deviation_on_Concentration_Data:  dcAvgStd  = hmrS_RunAvgStd(dcAvgRuns)
% Run_Average_Standard_Deviation_on_Delta_OD_Data:       dodAvgStd = hmrS_RunAvgStd(dodAvgRuns)
%

function yAvgStdOut = hmrS_RunAvgStd(yAvgRuns)

yAvgStdOut = DataClass().empty();
if isempty(yAvgRuns)
    return;
end
for iBlk = 1:length(yAvgRuns{1})
    yAvgStdOut(iBlk) = DataClass(yAvgRuns{1});
    foo = yAvgRuns{1}(iBlk).GetDataTimeSeries();
    dts = zeros(size(foo,1), size(foo,2), length(yAvgRuns));    
    for iRun = 1:length(yAvgRuns)
        dts(:,:,iRun) = yAvgRuns{iRun}(iBlk).GetDataTimeSeries();
    end
    yAvgStdOut(iBlk).SetDataTimeSeries(std(dts,1,3));
end
    
