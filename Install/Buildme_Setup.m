function Buildme_Setup(dirname)

dirnameInstall = pwd;
cd(dirname);

Buildme('setup');

cd(dirnameInstall);

