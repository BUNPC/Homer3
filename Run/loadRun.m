function run = loadRun(run,paramsLst)

% 
% Usage: 
%
%     run = loadRun(filename);
%     run = loadRun(filename, {'SD', 's', 'procInput'});
%     run = loadRun(run);
%     run = loadRun(run, {'SD', 's', 'procInput'});
%
% Description:
%
%     Loads run data from .nirs file to run structure. If paramsLst argument 
%     doesn't exist then by default all parameters from a .nirs file are loaded 
%     except for the following:
%
%          {procResult, d, t}
%     
%     To override the default and load all parameters, set paramsLst
%     argument to '+'.
%
% Examples:
%
%     1. Load all parameters from file Simple_Probe1_run02.nirs except
%     procResult, d, t into new struct run: 
%
%        run = loadRun('Simple_Probe1_run02.nirs');
%     
%     2. Load all parameters from file Simple_Probe1_run02.nirs into new struct run 
%
%        run = loadRun('Simple_Probe1_run02.nirs', {'+'});
%
%     3. Load parameters, SD, d, t, s, from file Simple_Probe1_run02.nirs into existing
%     struct run.
%
%        run = loadRun('Simple_Probe1_run02.nirs', {'SD','d','t','s'});
%
%

warning('off', 'MATLAB:load:variableNotFound');

if ~exist('run','var') | isempty(run)
    run=[];
    return;
end

if ischar(run)
    filename = run;
    run = struct('name',filename);
end

if ~exist(run.name, 'file')
    run = [];
    return;
end

if ~exist('paramsLst','var')
    paramsLst = {};
end

[paramsStr, paramsLst] = getParamsStr(run, paramsLst);
eval(sprintf('load(run.name,''-mat'', %s);', paramsStr));


%%%% load run variables

% NOTE: In all cases where the param exists in the file, we're counting 
% on it being error free according to the .nirs format. In other words, 
% we do no error checking of the source params - we assume they 
% are correct and any errors were eliminated during the initial error 
% checking phase.  
%

% First handle the variables that we know exist from the time the 
% .nirs fils was created 

if exist('d', 'var')
    run.d = d;
elseif ismember('d', paramsLst) || ~isprop(run, 'd')
    run.d = [];
end

if exist('t', 'var')
    run.t = t;
elseif ismember('t', paramsLst) || ~isprop(run, 't')
    run.t = [];
end

if exist('SD', 'var')
    run.SD = SetSDRun(SD);
elseif ismember('SD', paramsLst) || ~isprop(run, 'SD')
    run.SD = struct([]);
end

if exist('s', 'var')
    run.s = s;
elseif ismember('s',paramsLst) || ~isprop(run, 's')
    run.s = [];   
end

if exist('aux', 'var')
    run.aux = aux;
elseif ismember('aux',paramsLst) || ~isprop(run, 'aux')
    run.aux = [];
end

% Now handle the variables which Homer2 might have added in previous 
% subjects and saved. These variables might or might not exist in 
% the .nirs file.

if exist('CondNames','var')
    run.CondNames = CondNames;
elseif (ismember('CondNames', paramsLst) && ~exist('CondNames','var')) || ~isprop(run, 'CondNames')
    if  exist('s','var')
        run.CondNames = InitCondNamesRun(s);
    end
end
 
% if exist('tIncMan','var') && ismember('tIncMan', paramsLst)
%     run.tIncMan = tIncMan;
% elseif (ismember('tIncMan', paramsLst) && ~exist('tIncMan','var')) || ~isprop(run, 'tIncMan')
%     if exist('t','var')
%         run.tIncMan = ones(length(run.t),1);
%     end
% end
% 
% if exist('userdata','var') && ismember('userdata', paramsLst)
%     run.userdata = userdata;
% elseif (ismember('userdata', paramsLst) && ~exist('userdata','var')) || ~isprop(run, 'userdata')
%     if exist('s','var') && exist('t','var')
%         run.userdata = InitUserdata(s,t);
%     end
% end
% 
% if exist('procInput','var') && ismember('procInput', paramsLst)
%     if isproperty(run, 'procInput') && ~isempty(run.procInput)
%         run.procInput = copyStructFieldByField(run.procInput, procInput);
%     else
%         run.procInput = procInput;
%     end
% elseif (ismember('procInput', paramsLst) && ~exist('procInput','var')) || ~isproperty(run, 'procInput')
%     run.procInput = ProcInputClass();
% end
%    
% if exist('procResult','var') && ismember('procResult', paramsLst)
%     if isproperty(run, 'procResult') && ~isempty(run.procResult)
%         run.procResult = copyStructFieldByField(run.procResult, procResult);
%     else    
%         run.procResult = procResult;
%     end
% elseif (ismember('procResult', paramsLst) && ~exist('procResult','var')) || ~isproperty(run, 'procResult')
%     run.procResult = ProcResultClass();
% end

warning('on', 'MATLAB:load:variableNotFound');




% ---------------------------------------------------------
function [paramsStr, paramsLst] = getParamsStr(run, paramsLst)

paramsLstReadOnly  = {'d','aux','procResult'};
paramsLstReadWrite = {'t','SD','s','tIncMan','CondNames','userdata','procInput'};
paramsLstAll = [paramsLstReadOnly, paramsLstReadWrite];

% Determine the preliminary list of params
if isempty(paramsLst)
    paramsLst = paramsLstReadWrite;
end

for ii=1:length(paramsLstAll)
    
    if ~ismember(paramsLstAll{ii}, paramsLst) & ~isprop(run, paramsLstAll{ii}) & ismember(paramsLstAll{ii},paramsLstReadWrite)
        paramsLst{end+1} = paramsLstAll{ii};
    end
    if ~ismember(paramsLstAll{ii}, paramsLst)  & isprop(run, paramsLstAll{ii}) & eval(sprintf('isemptyRunParam(run.%s)',paramsLstAll{ii}))
        paramsLst{end+1} = paramsLstAll{ii};
    end
 
end

% Convert final list of params to single string
paramsStr='';
for ii=1:length(paramsLst)
    paramsStr = strcat(paramsStr,['''' paramsLst{ii} '''']);
    if ii<length(paramsLst)
        paramsStr = strcat(paramsStr,',');
    end
end



% ---------------------------------------------------------
function b = isemptyRunParam(param)

b=1;
if isstruct(param)
    
    fields=fieldnames(param);
    for ii=1:length(fields)
       if eval(sprintf('~isempty(param.%s);', fields{ii}))
           b=0;
       end
    end
    
elseif ~isempty(param)
    
    b=0;
    
end

