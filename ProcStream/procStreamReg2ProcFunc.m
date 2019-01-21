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

reg      = procStreamReg(type);
for ii=1:length(reg)
    S = textscan(reg{ii}, '%s');
    func(ii) = parseSection(S{1}, type);    
    func(ii).help = procStreamParseFuncHelp(func(ii));
end


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

