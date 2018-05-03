function datatype = getDatatype(axesData)

datatype=0;

plotRawVal  = get(axesData.handles.radiobuttonPlotRaw, 'value');
plotODVal   = get(axesData.handles.radiobuttonPlotOD, 'value');
plotConcVal = get(axesData.handles.radiobuttonPlotConc, 'value');
plotHRFVal  = get(axesData.handles.checkboxPlotHRF, 'value');

c = axesData.guisetting;

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
 

