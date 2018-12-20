function editPlotProbeAxScl_Callback(hObject, eventdata, handles)
global hmr

plotprobe = hmr.plotprobe;

foo = str2num( get(hObject,'string') );
if length(foo)<2
    foo = plotprobe.axScl;
elseif foo(1)<=0 | foo(2)<=0
    foo = plotprobe.axScl;
end    
plotprobe.axScl = foo;
set(hObject,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);

