function currElem = CalcCurrElem(currElem)

if strcmp(currElem.procElem.type, 'group')
    currElem.procElem.procResult = ...
    CalcGroup(currElem.procElem, currElem.handles.listboxFiles, currElem.funcPtrListboxFiles);
elseif strcmp(currElem.procElem.type, 'subj')
    currElem.procElem.procResult = ...
    CalcSubj(currElem.procElem, currElem.handles.listboxFiles, currElem.funcPtrListboxFiles);
elseif strcmp(currElem.procElem.type, 'run')
    currElem.procElem.procResult = ...
    CalcRun(currElem.procElem, currElem.handles.listboxFiles, currElem.funcPtrListboxFiles);
end
