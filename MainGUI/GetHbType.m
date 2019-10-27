function hbType = GetHbType(handles)

if nargin==0
    return
end
if isempty(handles)
    return
end
hbType = get(handles.listboxPlotConc, 'value');




