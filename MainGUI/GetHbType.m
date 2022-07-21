function hbType = GetHbType(handles)
hbType = '';
if nargin==0
    return
end
if isempty(handles)
    return
end
idx = get(handles.listboxPlotConc, 'value');
s = get(handles.listboxPlotConc, 'string');
if idx==0
    return;
end
if isempty(s)
    return;
end
for ii = 1:length(idx)
    hbType{ii} = s{idx(ii)};
end






