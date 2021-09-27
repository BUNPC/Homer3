function b = ispathvalid_startup(p, options)
% ispathvalid can replace matlab's o.isdir, o.isfile and exist functions
% all of which have flaws (e.g., isdir not fully backwards compatible, 
% exist has bugs where it'll confuse files and folders)
%
b = false;
if ~exist('options','var')
    options = '';
end
if ~ischar(options)
    return;
end
if ~isempty(options)
    if optionExists_startup(options,'file')
        
        % Err check 1.
        if isdir_private_startup(p)
            return;
        end
        
        % Err check 2.
        if optionExists_startup(options, 'checkextension')
            [~, ~, ext] = fileparts(p);
            if isempty(ext)
                return;
            end
        end
        
    elseif optionExists_startup(options,'dir')
        if isfile_private_startup(p)
            return;
        end
    else
        return;
    end
end
b = ~isempty(dir(p));

