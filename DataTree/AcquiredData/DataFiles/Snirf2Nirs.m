function Snirf2Nirs(rootdir, options)
if ~exist('rootdir','var')
    rootdir = pwd;
end
if ~exist('options','var')
    options = 'sort';
end
rootdir = filesepStandard(rootdir);
files = DataFilesClass(pwd, 'snirf');
for ii = 1:length(files)
    fname = filesepStandard([rootdir, files(1).name]);
    s = SnirfClass(fname);
    n = NirsClass(s);
    if optionExists(options, 'sort')
        n.SortData();
    end
    [pname, fname] = filesepStandard(fname);
    fnameNew = [pname, fname, '.nirs'];
    fprintf('Converting %s to %s\n', fname, fnameNew)
    n.Save(fnameNew);
end


