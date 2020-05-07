function demo_tcca()

% Set the various paths
rootpath = filesepStandard(fileparts(which('Homer3.m')));
currpath = pwd;
subjFolder = 'UnitTests/Example6_GrpTap';
subjFolder = [rootpath, subjFolder];
procStreamConfigFile = './processOpt_tcca.cfg';   % proc stream config file path relative to subject folder
cd(subjFolder);
resetGroupFolder('');

fprintf('Loading subject folder:  %s\n', subjFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change processing stream param values to newval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataTree = LoadDataTree(subjFolder, [], procStreamConfigFile);
iG = dataTree.GetCurrElemIndexID();
dataTree.groups(iG).Calc();
dataTree.groups(iG).Save();

cd(currpath)