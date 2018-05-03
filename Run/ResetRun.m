function run = ResetRun(run)

warning('off', 'MATLAB:load:variableNotFound');

% Check if there are original parameters saved 
load(run.name, '-mat','paramsOrig');

if exist('paramsOrig','var')
    SD = paramsOrig.SD;
    s = paramsOrig.s;
else
    SD = run.SD;
    s = run.s;
end

% t, d, and aux are stored in the file
load(run.name, '-mat','t','d','aux');
save(run.name, '-mat','SD','t','s','d','aux');

run = createRun(run.name, run.iSubj, run.iRun, run.rnum);

warning('on', 'MATLAB:load:variableNotFound');
