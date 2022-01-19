function printStack(ME)
global logger %#ok<NUSED>

if ~exist('ME','var')
    ME = [];
end

stdoutFuncName = getStandardOutputFuncName();

if isempty(ME)
    s = dbstack;
else
    s = ME.stack;
end

eval( sprintf('%s(''----------------------------------------------\\n'')', stdoutFuncName) );
if ~isempty(ME)
    eval( sprintf('%s(''ERROR:    %%s\\n'', ME.message)', stdoutFuncName) );
    eval( sprintf('%s(''Current Folder :  %%s\\n'', filesepStandard(pwd))', stdoutFuncName) );
end
eval( sprintf('%s(''Call stack:\\n'')', stdoutFuncName) );
for ii = 1:length(s)
    [~,f,e] = fileparts(s(ii).file); %#ok<*ASGLU>
    eval( sprintf('%s(''    Error in %%s > %%s (line %%d)\\n'', [f, e], s(ii).name, s(ii).line)', stdoutFuncName) );
end
eval( sprintf('%s(''----------------------------------------------\\n\\n'')', stdoutFuncName) );


