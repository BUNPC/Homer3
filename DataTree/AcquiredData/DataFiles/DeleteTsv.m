function DeleteTsv(rootdir)
if ~exist('rootdir','var')
    rootdir = pwd;
end
rootdir = filesepStandard(rootdir);
Snirf2Tsv(rootdir, 'remove');

