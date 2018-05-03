function procResult = procStreamCalcSubj(subj, hListboxFiles, listboxFilesFuncPtr)

procResult = InitProcResultSubj();

% Calculate all runs in this session
runs = subj.runs;
nRun = length(runs);
procResult_runs = cell(nRun,1);
for iRun = 1:nRun
    procResult_runs{iRun} = CalcRun(runs(iRun), hListboxFiles, listboxFilesFuncPtr);

    % Find smallest tHRF among the runs. We should make this the common one.
    if iRun==1
        tHRF_common = procResult_runs{iRun}.tHRF;
    elseif length(procResult_runs{iRun}.tHRF) < length(tHRF_common)
        tHRF_common = procResult_runs{iRun}.tHRF;
    end
end

listboxFilesFuncPtr(hListboxFiles, [subj.iSubj, 0]);

% Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for 
% all runs. Use smallest tHRF as the common one.
for iRun = 1:nRun
    procResult_runs{iRun} = procStream_tHRFCommon(procResult_runs{iRun}, tHRF_common,...
                                                  runs(iRun).name, 'run');
end


% Calculate all runs in a subject
nTrials = zeros(1,length(subj.CondNames));
nRun = length(runs);
for iRun = 1:nRun
    dodAvgRuns{iRun}    = procResult_runs{iRun}.dodAvg;
    dodAvgStdRuns{iRun} = procResult_runs{iRun}.dodAvgStd;
    dodSum2Runs{iRun}   = procResult_runs{iRun}.dodSum2;
    dcAvgRuns{iRun}     = procResult_runs{iRun}.dcAvg;
    dcAvgStdRuns{iRun}  = procResult_runs{iRun}.dcAvgStd;
    dcSum2Runs{iRun}    = procResult_runs{iRun}.dcSum2;
    tHRFRuns{iRun}      = procResult_runs{iRun}.tHRF;
    nTrialsRuns{iRun}   = procResult_runs{iRun}.nTrials;
    if ~isempty(procResult_runs{iRun}.SD)
        SDRuns{iRun}    = procResult_runs{iRun}.SD;
    else
        SDRuns{iRun}    = runs(iRun).SD;
    end
end

procElem = subj;

procStreamCalc();

