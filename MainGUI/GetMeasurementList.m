function ml = GetMeasurementList(handles)
global maingui

ml = [];

datatype    = GetDatatype(handles);
if datatype == maingui.buttonVals.RAW   ||  datatype == maingui.buttonVals.OD
    ml = maingui.dataTree.currElem.GetMeasurementList('matrix', 1, 'raw');
elseif datatype == maingui.buttonVals.CONC
    ml = maingui.dataTree.currElem.GetMeasurementList('matrix', 1, 'conc');
elseif datatype == maingui.buttonVals.OD_HRF
    ml = maingui.dataTree.currElem.GetMeasurementList('matrix', 1, 'od hrf');
elseif datatype == maingui.buttonVals.CONC_HRF
    ml = maingui.dataTree.currElem.GetMeasurementList('matrix', 1, 'conc hrf');
end

