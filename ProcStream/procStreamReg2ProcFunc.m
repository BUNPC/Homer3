function [func, reg] = procStreamReg2ProcFunc(varargin)

if nargin>0
    if ischar(varargin{1})
        type = varargin{1};
    else
        type = class(varargin{1});
    end
else
    type = '';
end
procInput = ProcInputClass();
reg      = procStreamReg(type);
for ii=1:length(reg)
    S = textscan(reg{ii}, '%s');
    procInput.Parse(S{1}, ii);
    procInput.func(ii).help = FuncHelpClass(procInput.func(ii).name);
end
func = procInput.func;



% -------------------------------------------------------------------
function regstrs = procStreamReg(type)
global procStreamGui

regstrs = {};

funcReg = procStreamGui.funcReg;

% Initialize output struct
switch(type)
    case {'group','GroupClass'}
        regstrs = funcReg.GetUsageStrsGroup();
    case {'subj','SubjClass'}
        regstrs = funcReg.GetUsageStrsSubj();
    case {'run','RunClass'}
        regstrs = funcReg.GetUsageStrsRun();
    otherwise
        regstrs = funcReg.GetUsageStrsAll();
end

