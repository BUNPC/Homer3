% SYNTAX:
% [yAvgStd, yAvgStdErr] = hmrG_SubjAvgStd(ySubjAvg)
%
% UI NAME:
% Subj_Average_Standard_Deviation_and_Standard_Error
%
% DESCRIPTION:
% Calculate avearge HRF standard deviation and standard error of all subjects in a group.
%
% INPUTS:
% ySubjAvg:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across subjects.
% yAvgStdErrOut: the standard error across subjects.
%
% USAGE OPTIONS:
% Subj_Average_Standard_Deviation_on_Concentration_Data:  [dcAvgStd, dcAvgStdErr]  = hmrG_SubjAvgStd(dcAvgSubjs)
% Subj_Average_Standard_Deviation_on_Delta_OD_Data:       [dodAvgStd, dodAvgStd] = hmrG_SubjAvgStd(dodAvgSubjs)
%

function [yAvgStdOut, yAvgStdErrOut] = hmrG_SubjAvgStd(ySubjAvg)

yAvgStdOut = DataClass().empty();
yAvgStdErrOut = DataClass().empty();

if isempty(ySubjAvg)
    return;
end
for iBlk = 1:length(ySubjAvg{1})
    yAvgStdOut(iBlk) = DataClass(ySubjAvg{1});
    yAvgStdErrOut(iBlk) = DataClass(ySubjAvg{1});
    foo = ySubjAvg{1}(iBlk).GetDataTimeSeries();
    dts = zeros(size(foo,1), size(foo,2), length(ySubjAvg));
    for iRun = 1:length(ySubjAvg)
        dts(:,:,iRun) = ySubjAvg{iRun}(iBlk).GetDataTimeSeries();
    end
    yAvgStdOut(iBlk).SetDataTimeSeries(std(dts,0,3,'omitnan'));
    yAvgStdErrOut(iBlk).SetDataTimeSeries(std(dts,0,3,'omitnan')/sqrt(length(ySubjAvg)-1));
end

