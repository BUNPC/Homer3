function editPlotProbeTimeMarkersAmp_Callback(hObject, eventdata, handles)
global hmr

plotprobe = hmr.plotprobe;
guiMain   = hmr.guiMain;

datatype    = guiMain.datatype;
buttonVals  = guiMain.buttonVals;

plotprobe.tMarkAmp = str2num(get(hObject,'string'));
if datatype == buttonVals.CONC_HRF
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
end

plotprobe = plotProbeAndSetProperties(plotprobe);

hmr.plotprobe = plotprobe;
