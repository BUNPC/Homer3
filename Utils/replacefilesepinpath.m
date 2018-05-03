function pathname = replacefilesepinpath(pathname)

%
% Usage:
%    pathname = replacefilesepinpath(pathname)
%
% Takes a pathname as argument and replaces any non-standard file/folder
% separators with standard ones, that is '/'. It also gets rid of redundant
% file seps
% 
% Example: 
%    
%   >> pathname = 'C:\dir1\\\dir2\\dir3\test1/\test2/'
%   >> pathname = replacefilesepinpath(pathname)
%
%   pathname =
%
%   C:/dir1/dir2/dir3/test1/test2/
%
%

[pp,fs] = getpathparts(pathname);
pathname = buildpathfrompathparts(pp,fs);
if isdir(pathname)
    if ~isempty(pathname) & pathname(end)~='/' & pathname(end)~='\'
        pathname(end+1)='/';
    elseif ~isempty(pathname) & pathname(end)=='\'
        pathname(end)='/';
    end
elseif ~isempty(pathname) & (pathname(end)=='\' | pathname(end)=='/')
    pathname(end)=[];
end