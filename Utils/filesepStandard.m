function pathname = filesepStandard(pathname0, options)

%
% Usage:
%    pathname = filesepStandard(pathname, options)
%
% Takes a pathname as argument and replaces any non-standard file/folder
% separators with standard ones, that is '/'. It also gets rid of redundant
% file seps
% 
% Example: 
%    
%   >> pathname = 'C:\dir1\\\dir2\\dir3\test1/\test2/'
%   >> pathname = filesepStandard(pathname)
%
%   pathname =
%
%   C:/dir1/dir2/dir3/test1/test2/
%
%

pathname = '';

if ~exist('options', 'var')
    options = '';
end
if ~optionExists(options,'nameonly')
    if ~ispathvalid(pathname0)
        return
    end
end

idxs = [];
k = find(pathname0=='\' | pathname0=='/');
for ii = 1:length(k)
    if (ii>1) && (k(ii) == k(ii-1)+1)
        idxs = [idxs, k(ii)];
        continue;
    end
    pathname0(k(ii)) = '/';
end
pathname0(idxs) = '';

if isdir(pathname0) && pathname0(end) ~= '/'
    pathname0(end+1) = '/';
end
pathname = pathname0;

