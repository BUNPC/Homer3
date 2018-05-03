function currElem = ResetCurrElem(currElem)

if currElem.procType==1
    currElem.procElem = ResetGroup(currElem.procElem);
elseif currElem.procType==2
    currElem.procElem = ResetSubj(currElem.procElem);
elseif currElem.procType==3
    currElem.procElem = ResetRun(currElem.procElem);
end
