function procInput = procStreamCopy2Native(procInput, ver)

procFunc = procInput.procFunc;
verNative = getVernum();

% Check if version can tell us if procInput is compatible with our version
if exist('ver','var') & ~isempty(ver)
    
    C = textscan(ver,'%s');
    if ~isempty(C)
        name = C{1}{1};
        num  = C{1}{2};
        if strcmpi(name, 'Homer3')
            return;
        end
    end
    
end

% If no version info then check data compatibility directly by looking at
% the data. 
if isempty(procFunc)
    return;
end
if isproperty(procFunc(1), 'funcName') && ischar(procFunc(1).funcName)
    return;
end
if ~isproperty(procFunc(1), 'nFunc')
    return;
end


% We determined that procInput is an older format that has to be converted to the native format
procFunc2 = struct([]);
for ii=1:procFunc.nFunc
    procFunc2(ii).funcName        = procFunc.funcName       {ii};
    procFunc2(ii).funcNameUI      = procFunc.funcNameUI     {ii};
    procFunc2(ii).funcArgIn       = procFunc.funcArgIn      {ii};
    procFunc2(ii).funcArgOut      = procFunc.funcArgOut     {ii};
    procFunc2(ii).nFuncParam      = procFunc.nFuncParam     (ii);
    procFunc2(ii).nFuncParamVar   = procFunc.nFuncParamVar  (ii);
    procFunc2(ii).funcParam       = procFunc.funcParam      {ii};
    procFunc2(ii).funcParamFormat = procFunc.funcParamFormat{ii};
    procFunc2(ii).funcParamVal    = procFunc.funcParamVal   {ii};
    procFunc2(ii).funcHelpStr     = '';
    procFunc2(ii).funcHelp        = InitHelp(procFunc.nFuncParam(ii));
end

procInput.conversionFlag  = true;
procInput.procFunc = procFunc2;

