function procResult = procStreamCalcGroup(group, hListboxFiles, listboxFilesFuncPtr)

procResult = InitProcResultGroup();

% Calculate all runs in this session
subjs = group.subjs;
nSubj = length(subjs);
procResult_subjs = cell(nSubj,1);
for iSubj = 1:nSubj
    procResult_subjs{iSubj} = CalcSubj(subjs(iSubj), hListboxFiles, listboxFilesFuncPtr);

    % Find smallest tHRF among the subjs. We should make this the common one.
    if iSubj==1
        tHRF_common = procResult_subjs{iSubj}.tHRF;
    elseif length(procResult_subjs{iSubj}.tHRF) < length(tHRF_common)
        tHRF_common = procResult_subjs{iSubj}.tHRF;
    end
end


listboxFilesFuncPtr(hListboxFiles, [0,0]);

% Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for 
% all subjs. Use smallest tHRF as the common one.
for iSubj = 1:nSubj
    procResult_subjs{iSubj} = procStream_tHRFCommon(procResult_subjs{iSubj}, tHRF_common,...
                                                    subjs(iSubj).name, 'subj');
end


% Calculate all subjs in a subject
nSubjs = length(subjs);
for iSubj = 1:nSubjs
    dodAvgSubjs{iSubj}    = procResult_subjs{iSubj}.dodAvg;
    dodAvgStdSubjs{iSubj} = procResult_subjs{iSubj}.dodAvgStd;
    dcAvgSubjs{iSubj}     = procResult_subjs{iSubj}.dcAvg;
    dcAvgStdSubjs{iSubj}  = procResult_subjs{iSubj}.dcAvgStd;
    tHRFSubjs{iSubj}      = procResult_subjs{iSubj}.tHRF;
    nTrialsSubjs{iSubj}   = procResult_subjs{iSubj}.nTrials;
    if ~isempty(procResult_subjs{iSubj}.SD)
        SDSubjs{iSubj}    = procResult_subjs{iSubj}.SD;
    else
        SDSubjs{iSubj}    = subjs(iSubj).SD;
    end    
end

procElem = group;

procStreamCalc();

