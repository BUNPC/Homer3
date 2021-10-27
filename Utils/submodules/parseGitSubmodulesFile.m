function modules = parseGitSubmodulesFile(repo)
modules = cell(0,3);

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
currdir = pwd;

repo = filesepStandard_startup(repo);

filename = [repo, '.gitmodules'];
if ~ispathvalid_startup(filename)
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
                modules{kk,2} = filesepStandard_startup([filesepStandard_startup(pwd), strs{ii+jj+2}], 'nameonly:dir');
            end
            if strcmp(strs{ii+jj}, 'path')
                modules{kk,3} = filesepStandard_startup(strs{ii+jj+2}, 'nameonly:dir');
            end
            if strcmp(strs{ii+jj}, 'url')
                modules{kk,1} = strs{ii+jj+2};
            end
            jj = jj+1;
        end
        kk = kk+1;
    end
end
fclose(fid);

cd(currdir);

