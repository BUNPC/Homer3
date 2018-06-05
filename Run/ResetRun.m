function run = ResetRun(run)

warning('off', 'MATLAB:load:variableNotFound');

% Check if there are original parameters saved 
load(run.name, '-mat','paramsOrig');

if exist('paramsOrig','var')
    SD = paramsOrig.SD;
    s = paramsOrig.s;
elseif isproperty(run,'SD') & isproperty(run,'s')
    SD = run.SD;
    s = run.s;
else
    load(run.name, '-mat','SD','s');
end

% t, d, and aux are stored in the file
load(run.name, '-mat','t','d','aux');
save(run.name, '-mat','SD','t','s','d','aux');

if isproperty(run,'iSubj') & isproperty(run,'iRun') & isproperty(run,'rnum')
    run = RunClass(run.name, run.iSubj, run.iRun, run.rnum);
end

warning('on', 'MATLAB:load:variableNotFound');
