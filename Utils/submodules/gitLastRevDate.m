function [dateNum, dateStr] = gitLastRevDate(repo, file)
dateNum = 0;

if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard_startup(repo, 'full');
currdir = pwd;

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git log -1 --format=%%ci --date=short %s', file);
[errs, msgs] = exeShellCmds(cmds, false, true);
if all(errs==0)
    if ~isempty(msgs{2})
        ds = msgs{2};
    else
        ds = '';
        %ds = char(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss'));
    end
    [dateNum, dateStr] = datestr2datenum(ds);   
end

cd(currdir)

