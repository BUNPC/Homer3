function tdType = GetTdType(handles)
if nargin==0
    return
end
if isempty(handles)
    return
end
if strcmp(get(handles.listboxPlotTD, 'visible'), 'off')
    tdType = 0;  % no tdType
else
    tdType = get(handles.listboxPlotConc, 'value');
end




