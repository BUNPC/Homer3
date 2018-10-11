function radiobuttonShowHiddenMeas_Callback(hObject,handles)
global plotprobe

global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

bit1 = get(hObject,'value');
plotprobe.hidMeasShow = bit1;
bit0 = plotprobe.tMarkShow;

h = plotprobe.objs.Data.h;

procResult  = currElem.procElem.procResult;
ch          = currElem.procElem.GetMeasList();

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
end

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,ch,y,h);

