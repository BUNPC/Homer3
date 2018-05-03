function helpReg = procStreamRegHelp(currElem)


% Initialize output struct
if strcmpi(currElem.procElem.type,'group')
    helpReg = procStreamRegHelpGroup();
elseif strcmpi(currElem.procElem.type,'subj')
    helpReg = procStreamRegHelpSubj();
elseif strcmpi(currElem.procElem.type,'run')
    helpReg = procStreamRegHelpRun();
end


