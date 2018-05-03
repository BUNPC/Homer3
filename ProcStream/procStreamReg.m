function callReg = procStreamReg(procElem)

% Initialize output struct
if strcmpi(procElem.type,'group')
    callReg = procStreamRegGroup();
elseif strcmpi(procElem.type,'subj')
    callReg = procStreamRegSubj();
elseif strcmpi(procElem.type,'run')
    callReg = procStreamRegRun();
end
