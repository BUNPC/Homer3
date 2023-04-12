function [errs, msgs] = exeShellCmds(cmds, preview, quiet)
% Change #2
errs = zeros(length(cmds),1) - 1;
msgs = cell(length(cmds),1);

if nargin==0
    return;
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('quiet','var')
    quiet = false;
end
for ii = 1:length(cmds)
    if preview == false
        c = str2cell(cmds{ii}, ' ');
        if strcmp(c{1}, 'cd')
            try
                cd(c{2})
                errs(ii) = 0;
                msgs{ii} = '';
            catch
                errs(ii) = 1;
                msgs{ii} = 'ERROR: folder does not exist or is in use';
            end
        else
            [errs(ii), msgs{ii}] = system(cmds{ii});
        end
    end
    if quiet == false
        fprintf('%s\n', cmds{ii});
    end
end

