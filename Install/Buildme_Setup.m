function Buildme_Setup(dirnameInstall)
currdir = pwd;
if ~exist('dirnameInstall','var') | isempty(dirnameInstall)
    dirnameInstall = ffpath('Buildme.m');
end
if exist(dirnameInstall,'dir')
    cd(dirnameInstall);
end
Buildexe('setup');
cd(currdir);
