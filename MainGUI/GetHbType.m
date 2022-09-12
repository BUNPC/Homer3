function [hbTypeStr, hbTypeIdx] = GetHbType(handles)
hbTypeStr = {};
hbTypeIdx = [];
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
hbTypeStr = s(idx);
hbTypeIdx = idx;







