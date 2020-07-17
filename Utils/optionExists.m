function b = optionExists(option, value)

b = ~isempty(findstr(option, value)); %#ok<*FSTR>