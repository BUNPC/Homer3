function datatype = getDatatype(guiControls)

datatype=0;

plotRawVal  = get(guiControls.handles.radiobuttonPlotRaw, 'value');
plotODVal   = get(guiControls.handles.radiobuttonPlotOD, 'value');
plotConcVal = get(guiControls.handles.radiobuttonPlotConc, 'value');
plotHRFVal  = get(guiControls.handles.checkboxPlotHRF, 'value');

c = guiControls.buttonVals;

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
 
