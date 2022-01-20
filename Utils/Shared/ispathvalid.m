function b = ispathvalid(p, options)
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
    if optionExists(options,'file')
        
        % Err check 1.
        if isdir_private(p)
            return;
        end
        
        % Err check 2.
        if optionExists(options, 'checkextension')
            [~, ~, ext] = fileparts(p);
            if isempty(ext)
                return;
            end
        end
        
    elseif optionExists(options,'dir')
        if isfile_private(p)
            return;
        end
    else
        return;
    end
end

try
    b = ~isempty(dir(p));
catch
    b = ~isempty(ls(p));
end
