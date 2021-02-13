% SYNTAX:
% yAvgStd = hmrS_RunAvgStd3(yAvgRuns, yAvgStdRuns, nTrialsRuns)
%
% UI NAME:
% Run_Average_Standard_Deviation
%
% DESCRIPTION:
% Calculates a weighted avearge of HRF standard deviation across runs within a subject.
%
% INPUTS:
% yAvgRuns:
% yAvgStdRuns:
% nTrialsRuns:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across runs
%
% USAGE OPTIONS:
% Run_Average_Standard_Deviation_on_Concentration_Data:  dcAvgStd  = hmrS_RunAvgStd3(dcAvgRuns, dcAvgStdRuns, nTrialsRuns)
%

function yAvgStdOut = hmrS_RunAvgStd3(yAvgRuns, yAvgStdRuns, nTrialsRuns)

yAvgStdOut = DataClass();
N = 0;
var = 0;
nDataBlks = length(yAvgStdRuns{1}); 


for iBlk = 1:nDataBlks
    % get tHRF and ml from yAvgRuns
    tHRF    = yAvgRuns{1}(iBlk).GetTime();
    ml    = yAvgRuns{1}(iBlk).GetMeasListSrcDetPairs();
    yAvgStdOut(iBlk).SetTime(tHRF);
    yAvg    = yAvgRuns{1}(iBlk).GetDataTimeSeries('reshape');
    
      
    for iC = 1:size(nTrialsRuns{1}{1},2) % across conditions
        
        % get total number of trials per given condition
        for iRun = 1:length(yAvgStdRuns)
            N = N + nTrialsRuns{iRun}{iBlk}(iC);
        end
        
        % get average of variance across runs weighted by number of trials within a run
        for iRun = 1:length(yAvgStdRuns)
            yAvgStd    = yAvgStdRuns{iRun}(iBlk).GetDataTimeSeries('reshape');
            var = var + (nTrialsRuns{iRun}{iBlk}(iC)-1)/(N-1) * yAvgStd(:,:,:,iC).^2;
        end
        
        % get std and append
        yAvgStd_wa = sqrt(var);
        yAvgStdOut(iBlk).AppendDataTimeSeries(yAvgStd_wa);
        var = 0;
        N = 0;
        
        % add measlist field
        for iCh = 1:size(yAvg,3)
            yAvgStdOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
            yAvgStdOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
        end
        
    end
end

