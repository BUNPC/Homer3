function run = LoadCurrRun(varargin)

% LoadCurrRun loads the currently selected run from the group
% tree to the currElem object. 

if nargin==4
    group = varargin{1};
    iSubj = varargin{2};
    iRun = varargin{3};

    % Get current run from group tree
    run = group.subjs(iSubj).runs(iRun);
    paramsLst = {4};
elseif nargin==3
    group = varargin{1};
    iSubj = varargin{2};
    iRun = varargin{3};

    % Get current run from group tree
    run = group.subjs(iSubj).runs(iRun);
    paramsLst = {};
elseif nargin==2
    run = varargin{1};
    paramsLst = varargin{2};
else
    run = varargin{1};
    paramsLst = {};
end


% Any run fields which are read-only are stored only in the corresponding
% file and only their place-holders exist in the group tree. We load them 
% into memory only for the current run. 

iP=1;
if isParamEmpty(run.d)
    paramsLst{iP} = 'd';
    iP=iP+1;
end
if isParamEmpty(run.t)
    paramsLst{iP} = 't';
    iP=iP+1;
end
if isParamEmpty(run.SD)
    paramsLst{iP} = 'SD';
    iP=iP+1;
end
if isParamEmpty(run.aux)
    paramsLst{iP} = 'aux';
    iP=iP+1;
end
if isParamEmpty(run.tIncMan)
    paramsLst{iP} = 'tIncMan';
    iP=iP+1;
end
if isParamEmpty(run.s)
    paramsLst{iP} = 's';
    iP=iP+1;
end
if isParamEmpty(run.CondNames)
    paramsLst{iP} = 'CondNames';
    iP=iP+1;
end
if isParamEmpty(run.userdata)
    paramsLst{iP} = 'userdata';
    iP=iP+1;
end
if isParamEmpty(run.procInput)
    paramsLst{iP} = 'procInput';
    iP=iP+1;
end
if isParamEmpty(run.procResult)
    paramsLst{iP} = 'procResult';
    iP=iP+1;
end

% When loading current run we want to load all the parameters
% including the read-only and procResult. By default if the 
% paramLst is empty loadRun will not load read-only or 
% procResult.
if isempty(paramsLst)
    paramsLst = {'+'};
end

run = loadRun(run, paramsLst);




% -------------------------------------------------------------
function b = isParamEmpty(param)

b=1;
if isempty(param) 
    b = isempty(param);
    return;
end
if ~isstruct(param(1)) && ~isobject(param(1))
    b = isempty(param(1));
    return;
end

fields = fieldnames(param(1));
for ii=1:length(fields)
    eval( sprintf('b = isParamEmpty(param(1).%s);', fields{ii}) );
    if b==0
        return;
    end
end

