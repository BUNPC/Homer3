function datatype = getDatatype(guiMain)

datatype=0;

plotRawVal  = get(guiMain.handles.radiobuttonPlotRaw, 'value');
plotODVal   = get(guiMain.handles.radiobuttonPlotOD, 'value');
plotConcVal = get(guiMain.handles.radiobuttonPlotConc, 'value');
plotHRFVal  = get(guiMain.handles.checkboxPlotHRF, 'value');

c = guiMain.buttonVals;

if plotRawVal && ~plotHRFVal
    datatype      = c.RAW;
elseif plotRawVal && plotHRFVal
    datatype      = c.RAW_HRF;
elseif plotODVal && ~plotHRFVal
    datatype      = c.OD;
elseif plotODVal && plotHRFVal
    datatype      = c.OD_HRF;
elseif plotConcVal && ~plotHRFVal
    datatype      = c.CONC;
elseif plotConcVal && plotHRFVal
    datatype      = c.CONC_HRF;
end
 

