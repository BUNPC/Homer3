function Snirf2Tsv(rootdir, options)
if ~exist('rootdir','var')
    rootdir = pwd;
end
if ~exist('options','var')
    options = pwd;
end
rootdir = filesepStandard(rootdir);
files = DataFilesClass(rootdir, 'snirf');
files = files.files;
for ii = 1:length(files)
    if files(ii).IsDir()
        continue
    end
    fname = filesepStandard([files(ii).rootdir, files(ii).name]);
    [pname, fname, ext1] = fileparts(fname);
    k = strfind(fname, '_nirs');
    if isempty(k)
        k = length(fname)+1;
    end
    fnameNew = [filesepStandard(pname), fname(1:k-1), '_events.tsv'];
    src = [filesepStandard(pname), fname, ext1];
    dst = fnameNew;
    if optionExists(options, 'delete') || optionExists(options, 'remove')
        if ispathvalid(dst)
            fprintf('Deleting  %s\n', dst);
            delete(dst);
        end
    else
        fprintf('Converting   %s   to   %s\n', src, dst);
        SnirfFile2Tsv(src, dst, 'removeStim');
    end
end



