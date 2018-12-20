function editPlotProbeTimeMarkersInt_Callback(hObject, eventdata, handles)
global hmr

plotprobe = hmr.plotprobe;

tHRF     = plotprobe.tHRF;

foo = str2num( get(hObject,'string') );
if length(foo)~=1
    foo = plotprobe.tMarkInt;
elseif ~isnumeric(foo)
    foo = plotprobe.tMarkInt;
elseif foo<5 || foo>tHRF(end)
    foo = plotprobe.tMarkInt;
end

plotprobe.tMarkInt = foo;
set(hObject,'string', sprintf('%0.1f ',plotprobe.tMarkInt) );
plotProbeAndSetProperties(plotprobe);


