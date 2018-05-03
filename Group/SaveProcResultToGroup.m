function group = SaveProcResultToGroup(group, currElem)

iRun  =  currElem.iRun;
iSubj =  currElem.iSubj;
if strcmp(currElem.procElem.type, 'group')
    group.procResult = currElem.procElem.procResult;
elseif strcmp(currElem.procElem.type, 'subj')
    group.subjs(iSubj).procResult = currElem.procElem.procResult;
elseif strcmp(currElem.procElem.type, 'run')
    procResult = currElem.procElem.procResult;
    save(group.subjs(iSubj).runs(iRun).name, '-mat','-append', 'procResult');
end


