function procInput = procStreamCopy2Native(procInput, ver)

func = procInput.func;
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
if isempty(func)
    return;
end
if isproperty(func(1), 'funcName') && ischar(func(1).funcName)
    return;
end
if ~isproperty(func(1), 'nFunc')
    return;
end


% We determined that procInput is an older format that has to be converted to the native format
func = struct([]);
for ii=1:func.nFunc
    func(ii).funcName        = func.funcName       {ii};
    func(ii).funcNameUI      = func.funcNameUI     {ii};
    func(ii).funcArgIn       = func.funcArgIn      {ii};
    func(ii).funcArgOut      = func.funcArgOut     {ii};
    func(ii).nFuncParam      = func.nFuncParam     (ii);
    func(ii).nFuncParamVar   = func.nFuncParamVar  (ii);
    func(ii).funcParam       = func.funcParam      {ii};
    func(ii).funcParamFormat = func.funcParamFormat{ii};
    func(ii).funcParamVal    = func.funcParamVal   {ii};
    func(ii).funcHelpStr     = '';
    func(ii).funcHelp        = InitHelp(func.nFuncParam(ii));
end
func = procStreamSetHelp(func);
procInput.func = func;

