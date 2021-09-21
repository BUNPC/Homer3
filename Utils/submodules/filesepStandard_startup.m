function pathname = filesepStandard_startup(pathname0, options)

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

if nargin==0
    return
end
if isempty(pathname0)
    return
end
if ~ischar(pathname0) && ~iscell(pathname0)
    return
end

if ~exist('options', 'var')
    options = '';
end

if ischar(pathname0)
    pathname0 = removeExtraDots_startup(pathname0);
    
    % Do basic error check to see if path exists; if not wexist without
    % doing anything 
    if ~optionExists_startup(options,'nameonly')
        if ~ispathvalid_startup(pathname0)
            return
        end
    end
    
    % Change all path file separators to standard forward slash
    idxs = [];        
    k = find(pathname0=='\' | pathname0=='/');
    for ii = 1:length(k)
        if (ii>1) && (k(ii) == k(ii-1)+1)
            idxs = [idxs, k(ii)]; %#ok<AGROW>
            continue;
        end
        pathname0(k(ii)) = '/';
    end
    
    % Remove any extraneous file separators
    pathname0(idxs) = '';
        
    % Change path to full path if option requesting it exists
    if optionExists_startup(options,'full') || optionExists_startup(options,'fullpath') || optionExists_startup(options,'absolute')
        if ispathvalid_startup(pathname0)
            pathname0 = fullpath_startup(pathname0);
        end
    end
    
    % Add traling separator only for directory path names 
    if (isdir_private_startup(pathname0) || optionExists_startup(options, 'dir')) && ~optionExists_startup(options, 'file')
        if pathname0(end) ~= '/'
            pathname0(end+1) = '/';
        end
    elseif (isfile_private_startup(pathname0) || optionExists_startup(options, 'file')) && ~optionExists_startup(options, 'dir')
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    else
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    end
        
    % Change path to full path if option requesting it exists
    pathname = pathname0;
    return;
end
pathname = pathname0;

% Call filesepStandard recursively for all path names in cell array
for ii = 1:length(pathname)
    pathname{ii} = filesepStandard_startup(pathname{ii}, options);
end


