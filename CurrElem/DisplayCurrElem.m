function DisplayCurrElem(currElem, guiMain)

if currElem.procType==1
    DisplayGroup(currElem.procElem, guiMain);
elseif currElem.procType==2
    DisplaySubj(currElem.procElem, guiMain);
elseif currElem.procType==3
    DisplayRun(currElem.procElem, guiMain);
end
