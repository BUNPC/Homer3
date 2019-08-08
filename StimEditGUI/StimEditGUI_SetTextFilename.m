function StimEditGUI_SetTextFilename(name, handles)

if isempty(handles)
    return;
end
if ~ishandles(handles.textFilename)
    return;
end
n = length(name);
set(handles.textFilename, 'units','characters');
p = get(handles.textFilename, 'position');
set(handles.textFilename, 'position',[p(1), p(2), n+.50*n, p(4)]);
set(handles.textFilename, 'units','normalized');
set(handles.textFilename, 'string',name);
