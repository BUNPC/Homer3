function run = createRun(filename, iSubj, iRun, rnum)

run = repmat(struct('name','', ...
                    'type','', ...
                    'iSubj', 0, ...
                    'iRun', 0, ...
                    'rnum', 0, ...
                    'SD', struct([]), ...
                    't', [], ...
                    's', [], ...
                    'd', [], ...
                    'aux', [], ...
                    'tIncMan', [], ...
                    'CondNames', {}, ...
                    'CondRun2Group', [], ...
                    'userdata', struct([]), ...
                    'procInput', struct([]), ...
                    'procResult', struct([]) ...
                   ), 0, 0);

if isempty(filename)
    return;
end
if exist(filename,'file')~=2
    return;
end

run0 = loadRun(filename);

run(1).name       = filename;
run(1).type       = 'run';
run(1).iSubj      = iSubj;
run(1).iRun       = iRun;
run(1).rnum       = rnum;
if isfield(run0,'SD')
    run(1).SD         = run0.SD;
end
if isfield(run0,'t')
    run(1).t          = run0.t;
end
if isfield(run0,'s')
    run(1).s          = run0.s;
end
if isfield(run0,'d')
    run(1).d          = run0.d;
end
if isfield(run0,'aux')
    run(1).aux        = run0.aux;
end
if isfield(run0,'tIncMan')
    run(1).tIncMan    = run0.tIncMan;
end
if isfield(run0,'CondNames')
    run(1).CondNames  = run0.CondNames;
end
if isfield(run0,'CondRun2Group')
    run(1).CondRun2Group = run0.CondRun2Group;
end
if isfield(run0,'userdata')
    run(1).userdata   = run0.userdata;
end
if isfield(run0,'procInput')
    run(1).procInput  = procStreamCopy2Native(run0.procInput);
end
if isfield(run0,'procResult')
    run(1).procResult = run0.procResult;
end

