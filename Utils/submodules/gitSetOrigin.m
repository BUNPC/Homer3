function [cmds, errs, msgs] = gitSetOrigin(repo, url, preview, quiet)
cmds = {};
errs = [];
msgs = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('quiet','var')
    quiet = true;
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
if isOriginSet(repoFull, url)
    return
end
cmds{ii,1} = sprintf('git remote set-url origin %s', url); 

[errs, msgs] = exeShellCmds(cmds, preview, quiet);

cd(currdir);



% -----------------------------------------------------
function b = isOriginSet(repo, url)
cd(repo);
urlActual = gitGetOrigin(repo);
urlrootActual = fileparts(urlActual);
urlroot = fileparts(url);
b = strcmp(urlrootActual, urlroot);

