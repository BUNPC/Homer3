% SYNTAX:
% yAvgStd = hmrS_SessAvgStd(yAvgSess)
%
% UI NAME:
% Run_Average_Standard_Deviation
%
% DESCRIPTION:
% Calculate avearge HRF standard deviation of all runs for one subject. 
%
% INPUTS:
% yAvgSess:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across runs
%
% USAGE OPTIONS:
% Run_Average_Standard_Deviation_on_Concentration_Data:  dcAvgStd  = hmrS_SessAvgStd(dcAvgSess)
% Run_Average_Standard_Deviation_on_Delta_OD_Data:       dodAvgStd = hmrS_SessAvgStd(dodAvgSess)
%

function yAvgStdOut = hmrS_SessAvgStd(yAvgSess)

yAvgStdOut = DataClass().empty();
if isempty(yAvgSess)
    return;
end
for iBlk = 1:length(yAvgSess{1})
    yAvgStdOut(iBlk) = DataClass(yAvgSess{1});
    foo = yAvgSess{1}(iBlk).GetDataTimeSeries();
    dts = zeros(size(foo,1), size(foo,2), length(yAvgSess));    
    for iRun = 1:length(yAvgSess)
        dts(:,:,iRun) = yAvgSess{iRun}(iBlk).GetDataTimeSeries();
    end
    yAvgStdOut(iBlk).SetDataTimeSeries(std(dts,1,3));
end
    
