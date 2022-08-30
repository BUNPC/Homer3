function datatype = GetDatatype(handles)
global maingui

datatype=0;

if nargin==0
    return
end
if isempty(handles)
    return
end

plotRawVal  = get(handles.radiobuttonPlotRaw, 'value');
plotODVal   = get(handles.radiobuttonPlotOD, 'value');
plotConcVal = get(handles.radiobuttonPlotConc, 'value');
plotHRFVal  = get(handles.checkboxPlotHRF, 'value');

c = maingui.buttonVals;

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
maingui.datatype = datatype;
 
