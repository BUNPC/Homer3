function guiControls = InitGuiControls(handles)
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

axesSDG = InitAxesSDG(handles);
axesData = InitAxesData(handles, axesSDG);
guiControls = struct(...
                     'name', 'guiControls', ...
                     'handles', struct(...
                                       'radiobuttonProcTypeGroup', handles.radiobuttonProcTypeGroup, ...
                                       'radiobuttonProcTypeSubj', handles.radiobuttonProcTypeSubj, ...
                                       'radiobuttonProcTypeRun', handles.radiobuttonProcTypeRun, ...
                                       'radiobuttonPlotConc', handles.radiobuttonPlotConc, ...
                                       'radiobuttonPlotOD', handles.radiobuttonPlotOD, ...
                                       'radiobuttonPlotRaw', handles.radiobuttonPlotRaw, ...
                                       'checkboxPlotHRF', handles.checkboxPlotHRF, ...
                                       'checkboxPlotProbe', handles.checkboxPlotProbe, ...
                                       'listboxPlotWavelength', handles.listboxPlotWavelength, ...
                                       'listboxPlotConc', handles.listboxPlotConc, ...
                                       'popupmenuConditions', handles.popupmenuConditions, ...
                                       'menuItemViewHRFStdErr', handles.menuItemViewHRFStdErr ...
                                      ), ...
                     'datatype', 0, ...
                     'proclevel', 0, ...
                     'condition', 0, ...
                     'ch', 0, ...
                     'wl', 0, ...
                     'hbType', 0, ...
                     'sclConc', 1e6, ...                      % convert Conc from Molar to uMolar
                     'axesSDG', axesSDG, ...
                     'axesData', axesData, ...
                     'showStdErr', false, ... 
                     'flagPlotRange', 0, ...
                     'applyEditCurrNodeOnly', true ...
                 );

guiControls = UpdateAxesDataCondition(guiControls, dataTree);
setWl(guiControls, dataTree.currElem.GetWls());

guiControls.proclevel = getProclevel(handles);
guiControls.datatype  = getDatatype(handles);
guiControls.condition = getCondition(guiControls);
guiControls.wl        = getWl(guiControls, dataTree.currElem.GetWls());
guiControls.hbType    = getHbType(guiControls);
guiControls.ch        = axesSDG.iCh;

if strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'on');
    guiControls.showStdErr = true;
elseif strcmp(get(handles.menuItemViewHRFStdErr, 'checked'), 'off');
    guiControls.showStdErr = false;
end

if guiControls.datatype == hmr.buttonVals.RAW || guiControls.datatype == hmr.buttonVals.RAW_HRF

    set(guiControls.handles.listboxPlotWavelength, 'visible','on');
    set(guiControls.handles.listboxPlotConc, 'visible','off');
    
elseif guiControls.datatype == hmr.buttonVals.OD || guiControls.datatype == hmr.buttonVals.OD_HRF
    
    set(guiControls.handles.listboxPlotWavelength, 'visible','on');
    set(guiControls.handles.listboxPlotConc, 'visible','off');
    
elseif guiControls.datatype == hmr.buttonVals.CONC || guiControls.datatype == hmr.buttonVals.CONC_HRF
    
    set(guiControls.handles.listboxPlotWavelength, 'visible','off');
    set(guiControls.handles.listboxPlotConc, 'visible','on');
    
end

if get(handles.checkboxApplyProcStreamEditToAll, 'value')
    guiControls.applyEditCurrNodeOnly = false;
else
    guiControls.applyEditCurrNodeOnly = true;
end
