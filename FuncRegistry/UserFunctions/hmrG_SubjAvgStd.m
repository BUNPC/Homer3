% SYNTAX:
% yAvgStd = hmrG_SubjAvgStd(ySubjAvg)
%
% UI NAME:
% Subj_Average_Standard_Deviation
%
% DESCRIPTION:
% Calculate avearge HRF standard deviation of all subjects in a group . 
%
% INPUTS:
% ySubjAvg:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across subjects.
%
% USAGE OPTIONS:
% Subj_Average_Standard_Deviation_on_Concentration_Data:  dcAvgStd  = hmrG_SubjAvgStd(dcAvgSubjs)
% Subj_Average_Standard_Deviation_on_Delta_OD_Data:       dodAvgStd = hmrG_SubjAvgStd(dodAvgSubjs)
%

function yAvgStdOut = hmrG_SubjAvgStd(ySubjAvg)

yAvgStdOut = DataClass().empty();
if isempty(ySubjAvg)
    return;
end
for iBlk = 1:length(ySubjAvg{1})
    yAvgStdOut(iBlk) = DataClass(ySubjAvg{1});
    foo = ySubjAvg{1}(iBlk).GetDataTimeSeries();
    dts = zeros(size(foo,1), size(foo,2), length(ySubjAvg));    
    for iRun = 1:length(ySubjAvg)
        dts(:,:,iRun) = ySubjAvg{iRun}(iBlk).GetDataTimeSeries();
    end
    yAvgStdOut(iBlk).SetDataTimeSeries(std(dts,0,3));
end
    
