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
    func(ii).name        = func.funcName       {ii};
    func(ii).nameUI      = func.funcNameUI     {ii};
    func(ii).argIn       = func.funcArgIn      {ii};
    func(ii).argOut      = func.funcArgOut     {ii};
    func(ii).nParam      = func.nFuncParam     (ii);
    func(ii).nParamVar   = func.nFuncParamVar  (ii);
    func(ii).param       = func.funcParam      {ii};
    func(ii).paramFormat = func.funcParamFormat{ii};
    func(ii).paramVal    = func.funcParamVal   {ii};
    func(ii).helpStr     = '';
    func(ii).help        = InitHelp(func.nFuncParam(ii));
end
func = procStreamSetHelp(func);
procInput.func = func;

