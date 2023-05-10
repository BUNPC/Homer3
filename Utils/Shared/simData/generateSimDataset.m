function nirs = generateSimDataset(dirname, nSubj, nSess, nRuns, options)

% 

nirs = [];

t0 = tic;


if ~exist('dirname','var')
    dirname = filesepStandard(pwd);
end
if ~exist('nSubj','var')
    nSubj = 3;
end
if ~exist('nSess','var')
    nSess = 3;
end
if ~exist('nRuns','var')
    nRuns = 3;
end
if ~exist('options','var')
    options = 'probe:springs';
end

% Create template data
setNamespace('AtlasViewerGUI');
dirnameAtlas = getAtlasDir();
if ~ispathvalid(dirnameAtlas)
    return;
end
refpts = initRefpts();
refpts = getRefpts(refpts, dirnameAtlas);
SD = genProbeFromRefpts(refpts, 36, 2, options);
nirs = NirsClass(SD);

% Generate stims
ntpts = 2000;
ncond = 4;
nstim = 7;
offset = 20;
stimInt = uint32((ntpts - offset)/nstim);
nirs.s = zeros(ntpts, ncond);
for iC = 1:ncond
    nirs.CondNames{iC}  = sprintf('cond%d', iC);
    k = offset : stimInt  : ntpts;
    nirs.s(k,iC) = 1;
    offset = offset+50;
end


%
for iSubj = 1:nSubj
    sname = sprintf('subj-%d', iSubj);
    if ispathvalid([dirname, sname])
        rmdir([dirname, sname], 's')
    end
    mkdir([dirname, sname]);

    for iRun = 1:nRuns
        for iM = 1:size(nirs.SD.MeasList,1)
            [nirs.t, nirs.d(:,iM)] = simulateDataTimeSeries(ntpts, 1, .4, t0);
        end
        snirf = SnirfClass(nirs.d, nirs.t, nirs.SD, [], nirs.s, nirs.CondNames);
        if iRun<10
            rname = sprintf('%s%s/%s_run0%d.snirf', dirname, sname, sname, iRun);
        else
            rname = sprintf('%s%s/%s_run%d.snirf', dirname, sname, sname, iRun);
        end
        snirf.Save(rname);
        fprintf('Created run %s\n', rname);
    end
end
 
