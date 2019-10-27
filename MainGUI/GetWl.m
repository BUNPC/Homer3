function iWl = GetWl(handles)
global maingui

iWl=[];
if nargin==0
    return
end
if isempty(handles)
    return
end

Lambda =  maingui.dataTree.currElem.GetWls();

val = get(handles.listboxPlotWavelength, 'value');
strs = get(handles.listboxPlotWavelength, 'string');
if isempty(strs)
    return;
end
if isempty(val>length(strs))
    return;
end

for ii=1:length(val)
    k = findstr('nm', strs{val(ii)});
    if isempty(k)
        k=length(strs{val(ii)})+1;
    end
    wl(ii) = str2num(strs{val(ii)}(1:k-1));
    iWl(ii) = find(Lambda==wl(ii));
end

