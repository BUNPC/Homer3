function radiobuttonShowTimeMarkers_Callback(hObject, evendata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

bit0 = get(hObject,'value');
plotprobe.tMarkShow = bit0;
bit1 = plotprobe.hidMeasShow;
h = plotprobe.objs.Data.h;

procResult  = currElem.procElem.procResult;
SD          = currElem.procElem.SD;

datatype    = guiMain.datatype;
buttonVals  = guiMain.buttonVals;


if currElem.procType==1
    condition  = guiMain.condition;
elseif currElem.procType==2
    condition = find(currElem.procElem.CondName2Group == guiMain.condition);
elseif currElem.procType==3
    condition  = find(currElem.procElem.CondName2Group == guiMain.condition);
end

if datatype == buttonVals.OD_HRF_PLOT_PROBE
    y = procResult.dodAvg(:, :, condition);
elseif datatype == buttonVals.CONC_HRF_PLOT_PROBE
    y = procResult.dcAvg(:, :, :, condition);
else
    return;
end

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,SD,y,h);

hmr.plotprobe = plotprobe;

