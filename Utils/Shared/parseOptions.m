function options = parseOptions(options_str, legal_options)

options = struct();

if ~exist('legal_options','var')
    legal_options = {
            {'add','remove'}
            {'conflcheck','noconflcheck'}
            {'mvpathconfl','rmpathconfl'}
            {'quiet','verbose'}
            {'fluence_simulate','nofluence_simulate'}
            {'nodiffnames','diffnames'}
    };
end

% Create options struct with options fields and set the defaults
for ii=1:size(legal_options,1)
    eval( sprintf('options.%s = true;', legal_options{ii}{1}) );
    eval( sprintf('options.%s = false;', legal_options{ii}{2}) );
end


% In input is numeric then assign that value to add option and exit
if exist('options_str','var') && ~ischar(options_str)
    if ~options_str==0 && ~options_str==1
        return;
    end
    options.add = options_str;
    options.remove = ~options_str;
    return;
end

C = str2cell(options_str, {':',',','+',' '});

% Error checking of string input
if exist('options_str','var')
    for ii=1:size(legal_options,1)
        if ~isempty(find(strcmp(C, legal_options{ii}{1}))) && ~isempty(find(strcmp(C, legal_options{ii}{2})))
            fprintf('Argument Error: Can''t have both %s and %s selected. Defaulting to %s\n', ...
                legal_options{ii}{1}, legal_options{ii}{2}, legal_options{ii}{1});
            return;
        elseif ~isempty(find(strcmp(C, legal_options{ii}{1}))) && isempty(find(strcmp(C, legal_options{ii}{2})))
            eval( sprintf('options.%s = true;', legal_options{ii}{1}) );
            eval( sprintf('options.%s = false;', legal_options{ii}{2}) );
        elseif isempty(find(strcmp(C, legal_options{ii}{1}))) && ~isempty(find(strcmp(C, legal_options{ii}{2})))
            eval( sprintf('options.%s = false;', legal_options{ii}{1}) );
            eval( sprintf('options.%s = true;', legal_options{ii}{2}) );
        end
    end
end

