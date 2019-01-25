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
    procInput.func(ii).help = FuncHelpClass(procInput.func(ii));
end
func = procInput.func;

% -------------------------------------------------------------------
function reg = procStreamReg(type)

reg = {};

% Initialize output struct
switch(type)
    case {'group','GroupClass'}
        reg = procStreamRegGroup();
    case {'subj','SubjClass'}
        reg = procStreamRegSubj();
    case {'run','RunClass'}
        reg = procStreamRegRun();
    otherwise
        reg = [reg; procStreamRegGroup()];
        reg = [reg; procStreamRegSubj()];
        reg = [reg; procStreamRegRun()];
end

