function stimGUI_EnableGuiObjects(onoff, handles)
if ~exist('handles','var') || isempty(handles)
    return;
end
if ~isstruct(handles)
    return;
end
fields = fieldnames(handles);
for ii=1:length(fields)
    sprintf('enableHandle(%s, onoff);', fields{ii});
end


% -----------------------------------------------------------
function enableHandle(handle, onoff)
if eval( sprintf('ishandles(obj.handles.%s)', handle) )
    eval( sprintf('set(obj.handles.%s, ''enable'',onoff);', handle) );
end


