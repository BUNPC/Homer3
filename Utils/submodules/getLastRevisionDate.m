function [dateNum, dateStr] = getLastRevisionDate(repo)
global synctool

dateNum = 0;
dateStr = '';
if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard(repo, 'full');
h = waitbar(0, sprintf('Please wait for date of last rev for "%s" ...', pathsubtract(repoFull, synctool.repoParentFull)));
f1 = findTypeFiles(repoFull, '.m');
f2 = findTypeFiles(repoFull, '.txt');
f3 = findTypeFiles(repoFull, '.numberfiles');
f = [f1; f2; f3];
for ii = 1:length(f)
    pathrel = pathsubtract(f{ii}, repoFull);
    [d, ds] = gitLastRevDate(repoFull, pathrel);
    if d>dateNum
        dateNum = d;
        dateStr = ds;
    end
    if mod(ii,10)==0
        waitbar(ii / length(f), h)
    end
end
close(h);

% % 
% fid = fopen([repoFull, 'Version.txt']);
% if fid<0
%     return
% end
% dateStr0 = fgetl(fid);
% dateNum0 = datestr2datenum(dateStr0);
% if dateNum > dateNum0
%     fprintf('Updating Version.txt:  replacing   %s   with   %s\n', dateStr0, dateStr);
%     fprintf(fid, dateStr);
% end
% fclose(fid);

% fprintf('%s\n', dateStr);
% fprintf('%f\n', dateNum);

