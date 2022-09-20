function Snirf2Nirs(rootdir, options)
if ~exist('rootdir','var')
    rootdir = pwd;
end
if ~exist('options','var')
    options = 'sort';
end
rootdir = filesepStandard(rootdir);
files = DataFilesClass(rootdir, 'snirf');
files = files.files;
for ii = 1:length(files)
    if files(ii).IsDir()
        continue
    end
    fname = filesepStandard([files(ii).rootdir, files(ii).name]);    
    s = SnirfClass(fname);
    n = NirsClass(s);
    if optionExists(options, 'sort')
        n.SortData();
    end
    [pname, fname] = fileparts(fname);
    fnameNew = [filesepStandard(pname), fname, '.nirs'];
    fprintf('Converting %s to %s\n', fname, fnameNew)
    n.Save(fnameNew);
end


