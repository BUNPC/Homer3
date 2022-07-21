function [d, t] = GetDataTimeSeries(handles)
global maingui

d = [];
t = [];

datatype    = GetDatatype(handles);
if datatype == maingui.buttonVals.RAW
    d = maingui.dataTree.currElem.GetDataTimeSeries();
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.OD
    d = maingui.dataTree.currElem.GetDataTimeSeries('od');
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.CONC
    d = maingui.dataTree.currElem.GetDataTimeSeries('conc');
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.OD_HRF
    d = maingui.dataTree.currElem.GetDataTimeSeries('od hrf');
    t = maingui.dataTree.currElem.GetTHRF();
elseif datatype == maingui.buttonVals.CONC_HRF
    d = maingui.dataTree.currElem.GetDataTimeSeries('conc hrf');
    t = maingui.dataTree.currElem.GetTHRF();
end
