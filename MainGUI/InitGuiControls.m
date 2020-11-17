function InitGuiControls(handles)
global maingui

maingui.buttonVals = struct(...
    'RAW',1, ...
    'RAW_HRF',2, ...
    'OD',4, ...
    'OD_HRF',8, ...
    'CONC',16, ...
    'CONC_HRF',32 ...
    );

maingui.axesSDG = InitAxesSDG(handles);
maingui.axesData = InitAxesData(handles, maingui.axesSDG);
maingui.sclConc = 1e6;                      % convert Conc from Molar to uMolar
maingui.plotViewOptions = struct('zoom',true, 'ranges',struct('X',[], 'Y',[]));

% Set the wavelength popup menu
% Load current element data from file
maingui.dataTree.LoadCurrElem();
Lambda =  maingui.dataTree.currElem.GetWls();
strs = cell(1,length(Lambda));
for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
if ~isempty(strs)
    set(handles.listboxPlotWavelength, 'string', strs);
end

% Decide which of the data type listboxes (Hb vs wavlength) is visible 
datatype = GetDatatype(handles);
if datatype == maingui.buttonVals.RAW || datatype == maingui.buttonVals.RAW_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == maingui.buttonVals.OD || datatype == maingui.buttonVals.OD_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == maingui.buttonVals.CONC || datatype == maingui.buttonVals.CONC_HRF
    set(handles.listboxPlotWavelength, 'visible','off');
    set(handles.listboxPlotConc, 'visible','on');
end

if get(handles.checkboxApplyProcStreamEditToAll, 'value')
    maingui.applyEditCurrNodeOnly = false;
else
    maingui.applyEditCurrNodeOnly = true;
end

UpdateCondPopupmenu(handles);
