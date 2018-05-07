function errflags = procStreamErrCheckGroup(procInput, group)

errflags = [];
iReg     = [];
procInputReg = [];
procFunc = procInput.procFunc;
if isempty(procFunc)
    return
end

% Search for procFun functions in procFuncStrReg
errflags = zeros(length(procFunc),1);
iReg = zeros(length(procFunc),1);

