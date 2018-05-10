function run = SaveRun(run, mode)
global hmr
group = hmr.group;

if ~exist('mode','var') | isempty(mode)
    mode = 'none';
end

iSubj = run.iSubj;
iRun = run.iRun;

group.subjs(iSubj).runs(iRun).SD         = run.SD;        
group.subjs(iSubj).runs(iRun).s          = run.s;         
group.subjs(iSubj).runs(iRun).tIncMan    = run.tIncMan;   
group.subjs(iSubj).runs(iRun).CondNames  = run.CondNames; 
group.subjs(iSubj).runs(iRun).userdata   = run.userdata;  
group.subjs(iSubj).runs(iRun).procInput  = run.procInput;
% Do not save procResult in memory. Too big.
% group.subjs(iSubj).runs(iRun).procResult = run.procResult;

paramsLst = {};
iP=1;

if ~strcmp(mode, 'none')
	procResult = run.procResult;
	paramsLst{iP} = 'procResult';
	iP=iP+1;
else
    run.procResult = InitProcResultRun();
end

if strcmpi(mode, 'savetodisk') || strcmpi(mode, 'saveuseredits')
    
    % If it hasn't been done already save all original read/write params
    warning('off', 'MATLAB:load:variableNotFound');
    load(run.name, '-mat','paramsOrig');
    warning('on', 'MATLAB:load:variableNotFound');

    if ~exist('paramsOrig','var')
        paramsOrig = load(run.name, '-mat','SD','s');
        paramsLst{iP} = 'paramsOrig';
        iP=iP+1;
    end
    
    SD = run.SD;
    paramsLst{iP} = 'SD';
    iP=iP+1;
    
    s = run.s;
    paramsLst{iP} = 's';
    iP=iP+1;

    tIncMan = run.tIncMan;
    paramsLst{iP} = 'tIncMan';
    iP=iP+1;

    CondNames = run.CondNames;
    paramsLst{iP} = 'CondNames';
    iP=iP+1;

    userdata = run.userdata;
    paramsLst{iP} = 'userdata';
    iP=iP+1;

    procInput = procStreamCopy2Old(run.procInput);
    paramsLst{iP} = 'procInput';
    iP=iP+1;

end

% Now we are ready to modify the .nirs file
if ~strcmp(mode, 'none')
	paramsStr = extractParams(paramsLst);
	eval(sprintf('save(run.name, ''-mat'',''-append'', %s);', paramsStr));
end
    
hmr.group = group;


% ---------------------------------------------------------
function [paramsStr paramsLst] = extractParams(paramsLst)


% Determine the preliminary list of params
if isempty(paramsLst) | strcmp(paramsLst{1},'+')
    paramsLst = {'t','SD','d','s','aux','tIncMan','CondNames','userdata','procInput','procResult'};
end

% Convert final list of params to single string
paramsStr='';
for ii=1:length(paramsLst)
    paramsStr = strcat(paramsStr,['''' paramsLst{ii} '''']);
    if ii<length(paramsLst)
        paramsStr = strcat(paramsStr,',');
    end
end

