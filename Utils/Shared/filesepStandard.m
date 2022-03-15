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
    pathname0 = removeExtraDots(pathname0);
    
    % Do basic error check to see if path exists; if not wexist without
    % doing anything 
    if ~optionExists(options,'nameonly')
        if ~ispathvalid(pathname0)
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
    if optionExists(options,'full') || optionExists(options,'fullpath') || optionExists(options,'absolute')
        if ispathvalid(pathname0)
            pathname0 = fullpath(pathname0);
        end
    end
    
    % Add traling separator only for directory path names 
    if (isdir_private(pathname0) || optionExists(options, 'dir')) && ~optionExists(options, 'file')
        if pathname0(end) ~= '/'
            pathname0(end+1) = '/';
        end
    elseif (isfile_private(pathname0) || optionExists(options, 'file')) && ~optionExists(options, 'dir')
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    else
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    end
    
    if optionExists(options, 'filesepwide')
        pathname0 = filesepwide(pathname0);
    end

    % Change path to full path if option requesting it exists
    pathname = pathname0;
    return;
end
pathname = pathname0;

% Call filesepStandard recursively for all path names in cell array
for ii = 1:length(pathname)
    pathname{ii} = filesepStandard(pathname{ii}, options);
end



% ---------------------------------------------------------------------------
function pname = removeExtraDots(pname)
k = cell(4,3);

% Case 1:
k{1,1} = strfind(pname, '/./');
k{2,1} = strfind(pname, '/.\');
k{3,1} = strfind(pname, '\.\');
k{4,1} = strfind(pname, '\./');
for ii = 1:length(k(:,1))
    for jj = length(k{ii,1}):-1:1
        pname(k{ii,1}(jj)+1:k{ii,1}(jj)+2) = '';
    end
end

% Case 2:
k{1,2} = strfind(pname, '/.');
k{2,2} = strfind(pname, '\.');
for ii = 1:length(k(:,2))
    if ~isempty(k{ii,2})
        if k{ii,2}+1<length(pname)
            continue
        end
        pname(k{ii,2}+1) = '';
    end
end



% --------------------------------------------------------------
function pathname = filesepwide(pathname0)
c = str2cell(pathname0, '/');
pathname = '';
for ii = 1:length(c)
    if isempty(pathname)
        if pathname0(1)=='/'
            pathname = ['/ ', c{ii}];
        else
            pathname = c{ii};
        end
    else
        pathname = sprintf('%s / %s', pathname, c{ii});
    end
end


