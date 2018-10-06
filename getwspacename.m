function [wspacename, wspath] = getwspacename(appname)

currdir = pwd;
dummydir = './tmp/';
if ~exist(dummydir,'dir')
    mkdir(dummydir);
end
cd(dummydir);

wspath = fileparts(which(appname));
[~, rootdir, ext] = fileparts(wspath);
wspacename = [rootdir, ext];

cd(currdir);
rmdir(dummydir, 's');

