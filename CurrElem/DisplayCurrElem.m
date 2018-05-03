function DisplayCurrElem(currElem, axesData)

if currElem.procType==1
    DisplayGroup(currElem.procElem, axesData);
elseif currElem.procType==2
    DisplaySubj(currElem.procElem, axesData);
elseif currElem.procType==3
    DisplayRun(currElem.procElem, axesData);
end
