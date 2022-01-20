function [cmds, errs, msgs] = gitSubmodulesUpdate(repo, options, preview)
cmds = {};


currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('options','var')
    options = 'init';
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');

ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git config --global http.sslverify "false"'); ii = ii+1;
cmds{ii,1} = sprintf('git submodule update --init --recursive --remote'); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

cd(currdir);

