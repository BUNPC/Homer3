function showStdErr = GetShowStdErrEnabled(handles)

if strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'on')
    showStdErr = true;
elseif strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'off')
    showStdErr = false;
end
