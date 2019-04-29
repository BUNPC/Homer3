function [title, vernum] = GuiMainVersion(varargin)
%
% Syntax:
%    [verstr, vernum, title] = GuiMainVersion()
%    [verstr, vernum, title] = GuiMainVersion(hObject)
%    [verstr, vernum, title] = GuiMainVersion(hObject, option)
%    [verstr, vernum, title] = GuiMainVersion(option)
% 
% Example:
%
%    [verstr, vernum, title] = GuiMainVersion('exclpath')
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
    title = sprintf('Homer3 (v%s) - %s', verstr, pwd);
elseif strcmp(option, 'exclpath')
    title = sprintf('Homer3 (v%s)', verstr);
end
if ishandle(hObject)
    set(hObject,'name', title);
end
