function procFunc = procStreamSetHelp(procElem)

procFunc = procElem.procInput.procFunc;
procFuncR = repmat(InitProcFunc(),0,1);

procFuncR = procStreamReg2ProcFunc(procElem);
procFunc = procStreamHelpParse(procFuncR, procFunc);

