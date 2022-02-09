function files = mydir(pathname, pathroot)

% SYNTAX:
%    files = mydir(pathname, pathroot)
%
% DESCRIPTION:
%
%    Modification of matlab's dir function to convert individual directories
%    to single file class object FileClass rather than an array of structs with 
%    the directory contents. Otherwise it behaves the same. To get the contents
%    of the folder use the wildcard character '*' OR file separator '/' or '\' 
%    at the end of the directory path name.
%
% EXAMPLES:
%
%    Example 1: Create FileClass object from folder
%
%        file = mydir('C:/rootdir/subdir1/subdir2/subdir3')
% 
%           FileClass with properties:
% 
%                   name: 'subdir3'
%                    fid: []
%                   date: '08-Nov-2021 20:35:21'
%                  bytes: 0
%                  isdir: 1
%                datenum: 7.3847e+05
%               namePrev: ''
%                    idx: 0
%               filename: 'Example4_twNI_alt2'
%              map2group: [1×1 struct]
%               rootdir: 'C:/rootdir/subdir1/subdir2/'
%                    err: 0
%                 logger: [1×1 Logger]
%
%
%    Example 2: Create array of FileClass objects with contents of folder
%
%        files = mydir('C:/rootdir/subdir1/subdir2/subdir3/*')
% 
%           1×5 FileClass array with properties:
% 
%                 name
%                 fid
%                 date
%                 bytes
%                 isdir
%                 datenum
%                 namePrev
%                 idx
%                 filename
%                 map2group
%                 rootdir
%                 err
%                 logger
% 
%           files(2) FileClass with properties:
% 
%                   name: 'file2.txt'
%                    fid: []
%                   date: '08-Nov-2021 20:35:21'
%                  bytes: 542
%                  isdir: 0
%                datenum: 7.3847e+05
%               namePrev: ''
%                    idx: 0
%               filename: 'processOpt_default.cfg'
%              map2group: [1×1 struct]
%                rootdir: 'C:/rootdir/subdir1/subdir2/subdir3/'
%                    err: 0
%                 logger: [1×1 Logger]
%


files = FileClass().empty();
if ~exist('pathname','var') || isempty(pathname)
    pathname = pwd;
end
if ~exist('pathroot','var') || isempty(pathroot)
    pathroot = pwd;
end

if ispathvalid(pathname, 'dir') && ~includes(pathname, '*')
    pathname(end+1) = '*';
end

dirs = dir(pathname);
if isempty(dirs)
    return;
end

for ii = 1:length(dirs)
    files(ii) = FileClass(dirs(ii), pathroot);
end

