function n = genNumberFile(pname)
n = [];
if ~exist('pname','var')
    pname = pwd;
end
pname = filesepStandard_startup(pname);
if ~ispathvalid_startup(pname)
    return
end
repos = {};
if ispathvalid_startup([pname, '.gitmodules'])
    s = parseGitSubmodulesFile();
    for ii = 1:size(s,1)
        repos{ii} = s{ii,2}; %#ok<AGROW>
    end
else
    repos{1} = pname;
end

n = zeros(1, length(repos));
for ii = 1:length(repos)
    filename = [repos{ii}, '.numberfiles'];
    fid = fopen(filename,'wt');
    files = findAllFiles(repos{ii});
    fprintf(fid, '%s', num2str(length(files)));
    fclose(fid);
    n(ii) = length(files);
end


