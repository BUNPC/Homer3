function errflags = procStreamErrCheckSubj(procInput, subj)

errflags = [];
iReg     = [];
procInputReg = [];
procFunc = procInput.procFunc;
if isempty(procFunc)
    return
end

% Search for procFun functions in procFuncStrReg
errflags = zeros(procFunc.nFunc,1);
iReg = zeros(procFunc.nFunc,1);

