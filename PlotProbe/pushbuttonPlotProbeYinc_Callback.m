function pushbuttonPlotProbeYinc_Callback(hObject, eventdata, handles)
global hmr 

plotprobe = hmr.plotprobe;

hEditScl = getSclPanelEditHandle(plotprobe.objs.SclPanel.h);

plotprobe.axScl(2) = plotprobe.axScl(2) + 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
plotprobe = plotProbeAndSetProperties(plotprobe);

hmr.plotprobe = plotprobe;
