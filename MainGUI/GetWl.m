function iWl = GetWl(handles)
iWl=[];
if nargin==0
    return
end
if isempty(handles)
    return
end
iWl = get(handles.listboxPlotWavelength, 'value');
