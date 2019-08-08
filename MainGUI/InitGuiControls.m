function InitGuiControls(handles)
global hmr
dataTree = hmr.dataTree;

hmr.buttonVals = struct(...
    'RAW',1, ...
    'RAW_HRF',2, ...
    'OD',4, ...
    'OD_HRF',8, ...
    'CONC',16, ...
    'CONC_HRF',32 ...
    );

hmr.axesSDG = InitAxesSDG(handles);
hmr.axesData = InitAxesData(handles, hmr.axesSDG);
hmr.sclConc = 1e6;                      % convert Conc from Molar to uMolar
hmr.plotViewOptions = struct('zoom',true, 'ranges',struct('X',[], 'Y',[]));

% Set the wavelength popup menu
Lambda =  hmr.dataTree.currElem.GetWls();
strs = cell(length(Lambda));
for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
if ~isempty(strs)
    set(handles.listboxPlotWavelength, 'string', strs);
end

% Decide which of the data type listboxes (Hb vs wavlength) is visible 
datatype = GetDatatype(handles);
if datatype == hmr.buttonVals.RAW || hmr.datatype == hmr.buttonVals.RAW_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == hmr.buttonVals.OD || hmr.datatype == hmr.buttonVals.OD_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == hmr.buttonVals.CONC || hmr.datatype == hmr.buttonVals.CONC_HRF
    set(handles.listboxPlotWavelength, 'visible','off');
    set(handles.listboxPlotConc, 'visible','on');
end

if get(handles.checkboxApplyProcStreamEditToAll, 'value')
    hmr.applyEditCurrNodeOnly = false;
else
    hmr.applyEditCurrNodeOnly = true;
end

UpdateCondPopupmenu(handles);
