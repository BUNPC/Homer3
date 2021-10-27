function b = optionExists_startup(options, option)
% Check if option (arg2) exists in a set of options (arg1)
b = false;
if isempty(options)
    return;
end
if iscell(options)
    options = options{1};
end
if ~ischar(options)
    return;
end

if ~exist('option','var') || isempty(option)
    b = false;
    return;
end
options2 = str2cell_startup(options,{':',';',','});
b = ~isempty(find(strcmp(options2,option))); %#ok<EFIND>

% b = ~isempty(findstr(options, option)); %#ok<*FSTR>
