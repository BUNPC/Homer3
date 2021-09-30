function s = setTerminal()
% This is needed on a MAC to execute some shell commands 
% Otherwise the system command executes its own shell that forces the user
% to press Enter key to continue matlab script execution.
s = '';
if ismac()
    s = 'TERM=ansi; ';
end

