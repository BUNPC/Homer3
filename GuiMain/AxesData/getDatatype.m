function datatype = getDatatype(guiMain)

datatype=0;

plotRawVal  = get(guiMain.handles.radiobuttonPlotRaw, 'value');
plotODVal   = get(guiMain.handles.radiobuttonPlotOD, 'value');
plotConcVal = get(guiMain.handles.radiobuttonPlotConc, 'value');
plotHRFVal  = get(guiMain.handles.checkboxPlotHRF, 'value');
plotProbe   = get(guiMain.handles.checkboxPlotProbe, 'value');

c = guiMain.buttonVals;

if plotRawVal && ~plotHRFVal && ~plotProbe
    datatype      = c.RAW;
elseif plotRawVal && plotHRFVal && ~plotProbe
    datatype      = c.RAW_HRF;
elseif plotRawVal && plotHRFVal && plotProbe
    datatype      = c.RAW_HRF_PLOT_PROBE;
elseif plotODVal && ~plotHRFVal && ~plotProbe
    datatype      = c.OD;
elseif plotODVal && plotHRFVal && ~plotProbe
    datatype      = c.OD_HRF;
elseif plotODVal && plotHRFVal && plotProbe
    datatype      = c.OD_HRF_PLOT_PROBE;
elseif plotConcVal && ~plotHRFVal && ~plotProbe
    datatype      = c.CONC;
elseif plotConcVal && plotHRFVal && ~plotProbe
    datatype      = c.CONC_HRF;
elseif plotConcVal && plotHRFVal && plotProbe
    datatype      = c.CONC_HRF_PLOT_PROBE;
end
 

