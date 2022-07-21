function [d, dStd, t] = GetDataTimeSeries(handles)
global maingui

d       = [];
dStd    = [];
t       = [];

showStdErr = GetShowStdErrEnabled(handles);
datatype   = GetDatatype(handles);

if datatype == maingui.buttonVals.RAW
    d = maingui.dataTree.currElem.GetDataTimeSeries();
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.OD
    d = maingui.dataTree.currElem.GetDataTimeSeries('od');
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.CONC
    d = maingui.dataTree.currElem.GetDataTimeSeries('conc') * maingui.sclConc;
    t = maingui.dataTree.currElem.GetTime();
elseif datatype == maingui.buttonVals.OD_HRF
    d = maingui.dataTree.currElem.GetDataTimeSeries('od hrf') * maingui.sclConc;
    t = maingui.dataTree.currElem.GetTHRF();
    if showStdErr
        dStd = maingui.dataTree.currElem.GetDataTimeSeries('od hrf std') * maingui.sclConc;
    end
elseif datatype == maingui.buttonVals.CONC_HRF
    d = maingui.dataTree.currElem.GetDataTimeSeries('conc hrf') * maingui.sclConc;
    t = maingui.dataTree.currElem.GetTHRF();
    if showStdErr
        dStd = maingui.dataTree.currElem.GetDataTimeSeries('conc hrf std') * maingui.sclConc;
    end
end

