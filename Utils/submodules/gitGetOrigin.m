function [url, cmds, errs, msgs] = gitGetOrigin(repo, preview, quiet)
url = '';
cmds = {};

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
cmds{ii,1} = sprintf('git remote -v'); kk = ii;

[errs, msgs] = exeShellCmds(cmds, preview, quiet);

c = str2cell_startup(msgs{kk}, {char(9), char(10), char(13), char(32)}); %#ok<CHARTEN>

for ii = 1:length(c)
    if ~isempty(strfind(c{ii},'http'))
        url = c{ii};
    end
end

cd(currdir);
