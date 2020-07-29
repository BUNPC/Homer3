function pth = ffpath(fname)
%   FFPATH    Find file path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function browses very fast current directory and directories known in 
% 'matlabpath' and the system variable 'path'. It searches for the file,
% name of which is in the input argument 'fname'. If a directory is found, 
% the output argument pth is filled by path to the file name from the input
% argument, otherwise pth is empty.
% File names should have their extensions, but MATLAB m-files.
% 
% Arguments:
%   fname   file name 
%   pth     path to the fname
%
% Examples:
%   pth = ffpath('gswin32c.exe')
%   pth =
%   c:\Program Files\gs\gs8.60\bin\
%
%   pth = ffpath('hgrc')
%   pth =
%   C:\PROGRA~1\MATLAB\R2006b\toolbox\local

% Miroslav Balda
% miroslav AT balda DOT cz
% 2008-12-15    v 0.1   only for system variable 'path'
% 2008-12-20    v 1.0   for both 'path' and 'matlabpath'

if nargin<1
    error('The function requires one input argument (file name)')
end
pth = pwd;
if exist([pth '/' fname],'file')
    return
end % fname found in current dir

tp = matlabpath;
t  = 0;
if isunix() | ismac()
    I = [t, findstr(tp,':'), length(tp)+1];
elseif ispc()
    I = [t, findstr(tp,';'), length(tp)+1];
end    
for k = 1:length(I)-1               %   search in path's directories
    pth = tp(I(k)+1:I(k+1)-1);
    % fprintf('%s\n', [pth '/' fname]);
    if exist([pth '/' fname],'file')
        return;
    end
end
[status,tp] = system('path');
t = 5;
pth = '';

