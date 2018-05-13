function reg = procStreamReg(varargin)

reg = {};
if nargin>0
    if isstruct(varargin{1})
        type = varargin{1}.type;
    elseif ischar(varargin{1})
        type = varargin{1};
    end    
else
    type = '';
end

% Initialize output struct
if strcmpi(type,'group')
    reg = procStreamRegGroup();
elseif strcmpi(type,'subj')
    reg = procStreamRegSubj();
elseif strcmpi(type,'run')
    reg = procStreamRegRun();
else
    reg = [reg; procStreamRegGroup()];
    reg = [reg; procStreamRegSubj()];
    reg = [reg; procStreamRegRun()];
end
