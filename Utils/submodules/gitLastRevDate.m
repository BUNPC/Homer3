function [date, datestr] = gitLastRevDate(repo, file)
date = 0;

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
    c = str2cell(msgs{2}, ' ');
    dateS = c{1};
    timeS = c{2};
    dateS(dateS=='-')='';
    timeS(timeS==':')='';    
    
    time = str2num(timeS);
    date = str2num(dateS) + time/1e6;
    
    datestr = [c{1}, ' ', c{2}];
end

cd(currdir)

