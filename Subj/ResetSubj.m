function subj = ResetSubj(subj)

subj.procResult = InitProcResultSubj();
subj.SD = [];
for kk=1:length(subj.runs)
    subj.runs(kk) = ResetRun(subj.runs(kk));
end
