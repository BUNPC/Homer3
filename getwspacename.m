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

% When removing folders it is a sensitive moment - make sure to catch
% exceptions signaliing failure to remove folder.
trycount = 1;
while trycount<10
    try
        rmdir(dummydir,'s');
        break;
    catch
        trycount = trycount+1;
    end
    pause(.1);
end


