function currElem = getProcType(currElem)

if ~ishandle(currElem.handles.radiobuttonProcTypeGroup)
    currElem.procType = 1;
    return;
end

if get(currElem.handles.radiobuttonProcTypeGroup,'value')
    currElem.procType = 1;
elseif get(currElem.handles.radiobuttonProcTypeSubj,'value')
    currElem.procType = 2;
elseif get(currElem.handles.radiobuttonProcTypeRun,'value')
    currElem.procType = 3;
end
