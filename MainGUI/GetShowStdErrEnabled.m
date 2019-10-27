function showStdErr = GetShowStdErrEnabled(handles)

showStdErr = [];

if nargin==0
    return
end
if isempty(handles)
    return
end
if strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'on')
    showStdErr = true;
elseif strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'off')
    showStdErr = false;
end
