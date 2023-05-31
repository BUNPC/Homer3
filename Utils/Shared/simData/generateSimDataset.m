function out = generateSimDataset(dirname, nSubj, nSess, nRuns, options)
%
% Syntax:
%   out = generateSimDataset()
%   out = generateSimDataset(dirname)
%   out = generateSimDataset(dirname, nSubj)
%   out = generateSimDataset(dirname, nSubj, nSess)
%   out = generateSimDataset(dirname, nSubj, nSess, nRuns)
%   out = generateSimDataset(dirname, nSubj, nSess, nRuns, options)
%
% Description:
%   options - { {'probe'|'digpts}, 'springs', 'data' }
%
% Examples:
%
%   %%%%% Change current folder to <root groups test folder>
%   emptyGroupTestDir = 'c:/users/public/groups/emptyGroupTestDir';
%   if ~exist(emptyGroupTestDir,'dir'), mkdir(emptyGroupTestDir); end
%   cd(emptyGroupTestDir);
%
%   %%%%% Now generate probe and/or digitized points and/or raw/unprocessed dataTree data.
%   %%%%% These 9 examples covers all the major AtlasViewer + Homer3 workflows
%
%   % Example 1: probe file in SD format with spring registration and
%   % raw/unprocessed dataTree data with 3 subjects, 3 sessions each, and 3 runs each.
%   out = generateSimDataset(pwd, 3, 3, 3, 'probe:springs:data');
%
%   % Example 2: probe file in SD format with spring registration and
%   % raw/unprocessed dataTree data with 3 subjects, 3 sessions each with 3 runs each.
%   out = generateSimDataset();
%
%   % Example 3: probe file in SD format with spring registration and
%   % acquisition data with 3 subjects, 1 session each, and 3 runs each.
%   out = generateSimDataset(pwd);
%
%   % Example 4: probe file in SD format with spring registration and acquisition data
%   % with 2 subjects with 1 session each, and each session with 5 runs each.
%   out = generateSimDataset(pwd, 2, 1, 5);
%
%   % Example 5: probe file in SD format with NO registration and NO acquisition data
%   out = generateSimDataset(pwd, [],[],[],'probe');
%
%   % Example 6: probe file in SD format with spring registration and NO data
%   out = generateSimDataset(pwd, [],[],[],'probe:springs');
%
%   % Example 7: Unprocessed dataTree data with 3 subjects, 3 sessions, and 3 runs each
%   % and with acquisition files containing probe with landmark registration.
%   % with 3 subjects with 1 session each, and each session with 3 runs each.
%   out = generateSimDataset(pwd, [],[],[],'probe:landmarks:data');
%
%   % Example 8: Digpts file with associated probe file in SD format containing measurement list
%   % and NO acquisition data
%   out = generateSimDataset(pwd, [],[],[],'digpts');
%
%   % Example 9: Digpts file with associated probe file in SD format containing measurement list
%   % and data with 1 subject with 2 sessions each, and each session with 4 runs each.
%   out = generateSimDataset(pwd, 1, 2, 4, 'digpts:data');
%
%
global atlasViewer
global probeFilename

atlasViewer = [];
probeFilename = 'newfile1.SD';

out = [];

t0 = tic;

if ~exist('dirname','var') || isempty(dirname)
    dirname = pwd;
end
if ~exist('nSubj','var') || isempty(nSubj)
    nSubj = 3;
end
if ~exist('nSess','var') || isempty(nSess)
    nSess = 1;
end
if ~exist('nRuns','var') || isempty(nRuns)
    nRuns = 3;
end
if ~exist('options','var')
    options = 'probe:springs:data';
end

dirname = filesepStandard(dirname);

% Reset folder to known state
resetDataset();

% Create template data
setNamespace('AtlasViewerGUI');
dirnameAtlas = getAtlasDir();
if ~ispathvalid(dirnameAtlas)
    return;
end
refpts = initRefpts();
refpts = getRefpts(refpts, dirnameAtlas);

if optionExists(options, 'probe')
    genProbeFromRefpts(refpts, 36, 2, options);
elseif optionExists(options, 'digpts')
    genDigptsFromRefpts(refpts, 36, 2);
end

if optionExists(options, 'data')
    digpts = initDigpts();
    digpts = getDigpts(digpts);
    probe  = initProbe();
    probe  = getProbe(probe, dirname, digpts);
    genSimData(probe, dirname, nSubj, nSess, nRuns, t0);
    subjDirs = dir('sub-*');
    for ii = 1:length(subjDirs)
        digptsNew = movePts(digpts, randNearZero(1,3,t0), randNearOne(1,3,t0), randNearZero(1,3,t0));
        digptsNew.pathname = [filesepStandard(dirname), subjDirs(ii).name];
        saveDigpts(digptsNew);
        if ispathvalid([dirname, probeFilename])
            if optionExists(options, 'springs')
                copyfile([dirname, probeFilename], [filesepStandard(dirname), subjDirs(ii).name, '/', probeFilename]);
            end
        end
    end
    delete('./digpts*.txt');
end



% ----------------------------------------------
function genSimData(probe, dirname, nSubj, nSess, nRuns, t0)
SD = convertProbe2SD(probe);
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

% Generate data
for iSubj = 1:nSubj
    if iSubj < 10
        iSubjName = sprintf('0%d', iSubj);
    else
        iSubjName = sprintf('%d', iSubj);
    end
    subjName = sprintf('sub-%s', iSubjName);
    subjNameFull = filesepStandard([dirname, subjName], 'dir:nameonly');
    if ispathvalid(subjNameFull)
        rmdir(subjNameFull, 's')
    end
    mkdir(subjNameFull);
    
    for iSess = 1:nSess
        if iSess < 10
            iSessName = sprintf('0%d', iSess);
        else
            iSessName = sprintf('%d', iSess);
        end
        sessName = sprintf('ses-%s', iSessName);
        sessNameFull = filesepStandard([subjNameFull, sessName], 'dir:nameonly');
        if ispathvalid(sessNameFull)
            rmdir(sessNameFull, 's')
        end
        mkdir(sessNameFull);
        
        for iRun = 1:nRuns
            for iM = 1:size(nirs.SD.MeasList,1)
                [nirs.t, nirs.d(:,iM)] = simulateDataTimeSeries(ntpts, 1, .4, t0);
            end
            snirf = SnirfClass(nirs.d, nirs.t, nirs.SD, [], nirs.s, nirs.CondNames);
            if iRun<10
                runNameFull = sprintf('%s%s_%s_run0%d.snirf', sessNameFull, subjName, sessName, iRun);
            else
                runNameFull = sprintf('%s%s_%s_run%d.snirf', sessNameFull, subjName, sessName, iRun);
            end
            snirf.Save(runNameFull);
            fprintf('Created run %s\n', runNameFull);
        end
    end
end


% -----------------------------------------------------------------
function resetDataset(dirname)
if ~exist('dirname','var')
    dirname = filesepStandard(pwd);
end

currdir = filesepStandard(pwd);
cd(dirname);

files = dir('*');
for ii = 1:length(files)
    if strcmpi(files(ii).name, '.')
        continue
    end
    if strcmpi(files(ii).name, '..')
        continue
    end
    if strcmpi(files(ii).name, 'anatomical')
        continue
    end
    if files(ii).isdir
        rmdir(files(ii).name,'s')
    else
        delete(files(ii).name)
    end
end
cd(currdir);




% -----------------------------------------------
function digpts = movePts(digpts, r, s, t)
if ~exist('r','var')
    r = [0,0,0];
end
if ~exist('s','var')
    s = [1,1,1];
end
if ~exist('t','var')
    t = [0,0,0];
end

alpha = deg2rad(r(1));
beta  = deg2rad(r(2));
theta = deg2rad(r(3));

A = [ ...
    1            0             0    0;
    0   cos(alpha)   -sin(alpha)    0;
    0   sin(alpha)    cos(alpha)    0;
    0            0             0    1;
    ];

B = [ ...
    cos(beta)    0     sin(beta)     0;
    0            1             0     0;
    -sin(beta)    0     cos(beta)     0;
    0            0             0     1;
    ];

C = [ ...
    cos(theta)   -sin(theta)   0     0;
    sin(theta)    cos(theta)   0     0;
    0            0             1     0;
    0            0             0     1;
    ];

D = [ ...
    1            0             0     t(1);
    0            1             0     t(2);
    0            0             1     t(3);
    0            0             0     1;
    ];

S = [ ...
    s(1)           0             0     0;
    0           s(2)           0     0;
    0            0           s(3)    0;
    0            0             0     1;
    ];

T = S*D*C*B*A;

digpts.srcpos = xform_apply(digpts.srcpos, T);
digpts.detpos = xform_apply(digpts.detpos, T);
digpts.refpts.pos = xform_apply(digpts.refpts.pos, T);



% ----------------------------------------------------------------
function r = randNearOne(w, h, t0)
generateRandNumSeed(t0);
r = ones(w,h) + (rand(w,h) - 0.5) / 2;



% ----------------------------------------------------------------
function r = randNearZero(w, h, t0)
generateRandNumSeed(t0);
r = (rand(w,h) - 0.5) / 2;



% ---------------------------------------------------
function generateRandNumSeed(time0)
if time0 == 0
    x = uint32(100*rand);
    rng(x);
    y = uint32(100*rand);
    rng(y);
else
    s = 0;
    while s==0
        s = uint64(1e4*toc(time0));
    end
    rng(s);
end

