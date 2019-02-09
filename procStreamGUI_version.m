function [title, vernum] = procStreamGUI_version(varargin)
%
% Syntax:
%    [verstr, vernum, title] = procStreamGUI_version()
%    [verstr, vernum, title] = procStreamGUI_version(hObject)
%    [verstr, vernum, title] = procStreamGUI_version(hObject, option)
%    [verstr, vernum, title] = procStreamGUI_version(option)
% 
% Example:
%
%    [verstr, vernum, title] = procStreamGUI_version('exclpath')
%

if nargin==0
        hObject = [];
        option  = '';
elseif nargin==1
    if ischar(varargin{1})
        hObject = [];
        option  = varargin{1};
    else
        hObject = varargin{1};
        option  = '';
    end
elseif nargin==2
    hObject = varargin{1};
    option  = varargin{2};
end
if ~ischar(option) || ~ismember(option, {'inclpath', 'exclpath'})
    option = '';
end

if isempty(hObject)
    hObject = -1;
end
if isempty(option)
    option = 'inclpath';
end
[verstr, vernum] = version2string();
if strcmp(option, 'inclpath')
    title = sprintf('procStreamGUI  (%s) - %s', verstr, pwd);
elseif strcmp(option, 'exclpath')
    title = sprintf('procStreamGUI (%s)', verstr);
end
if ishandle(hObject)
    set(hObject,'name', title);
end
