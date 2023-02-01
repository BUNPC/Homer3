function submodules = parseGitSubmodulesFile(repo)
submodules = cell(0,3);

if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
currdir = pwd;
if repo(end) ~= '/' && repo(end) ~= '\'
    repo = [repo, '/'];
end

filename = [repo, '.gitmodules'];
if ~exist(filename, 'file')
    return;
end
cd(repo);

fid = fopen(filename, 'rt');
strs = textscan(fid, '%s');
strs = strs{1};
kk = 1;
for ii = 1:length(strs)
    if strcmp(strs{ii}, '[submodule')
        jj = 1;
        while ~strcmp(strs{ii+jj}, '[submodule')
            if ii+jj+2>length(strs)
                break;
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,2} = [pwd, '/', strs{ii+jj+2}];
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,3} = strs{ii+jj+2};
            end
            if strcmp(strs{ii+jj}, 'url')
                submodules{kk,1} = strs{ii+jj+2};
            end
            jj = jj+1;
        end
        kk = kk+1;
    end
end
fclose(fid);
cd(currdir);



