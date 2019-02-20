function iWl = getWl(guiControls, Lambda)

iWl=[];
val = get(guiControls.handles.listboxPlotWavelength, 'value');
strs = get(guiControls.handles.listboxPlotWavelength, 'string');
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

