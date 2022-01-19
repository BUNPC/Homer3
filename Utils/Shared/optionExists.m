function b = optionExists(options, option)
% Check if option (arg2) exists in a set of options (arg1)

if isempty(options)
    b = false;
    return;
end
if ~exist('option','var') || isempty(option)
    b = false;
    return;
end
options2 = str2cell(options,{':',';',','});
b = ~isempty(find(strcmp(options2,option))); %#ok<EFIND>

% b = ~isempty(findstr(options, option)); %#ok<*FSTR>