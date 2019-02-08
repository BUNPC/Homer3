function [title, vernum] = Homer3_version(varargin)
%
% Syntax:
%    [verstr, vernum, title] = Homer3_version()
%    [verstr, vernum, title] = Homer3_version(hObject)
%    [verstr, vernum, title] = Homer3_version(hObject, option)
%    [verstr, vernum, title] = Homer3_version(option)
% 
% Example:
%
%    [verstr, vernum, title] = Homer3_version('exclpath')
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
    title = sprintf('Homer3  (%s) - %s', verstr, pwd);
elseif strcmp(option, 'exclpath')
    title = sprintf('Homer3 (%s)', verstr);
end
if ishandle(hObject)
    set(hObject,'name', title);
end
