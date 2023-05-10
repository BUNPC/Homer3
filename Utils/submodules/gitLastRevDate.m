function [dateNum, dateStr] = gitLastRevDate(repo, file)
dateNum = 0;
dateStr = '';

if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
if ~exist('file','var') || isempty(file)
    file = '';
end
repoFull = filesepStandard_startup(repo, 'full');
currdir = pwd;

if ismac()
    cmdprefix = 'TERM=ansi; ';
    e = system(cmdprefix);
    if e ~= 0
        return;
    end
else
    cmdprefix = '';
end

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('%sgit log -1 --format=%%ci --date=short %s', cmdprefix, file);
[errs, msgs] = exeShellCmds(cmds, false, true);
if all(errs==0)
    if ~isempty(msgs{2})
        ds = msgs{2};
    else
        ds = '';
        %ds = char(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss'));
    end
    [dateNum, dateStr] = datestr2datenum(ds(1:20));   
end
cd(currdir)

