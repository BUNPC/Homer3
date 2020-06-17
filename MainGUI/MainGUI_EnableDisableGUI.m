function MainGUI_EnableDisableGUI(handles, val)
    set(handles.listboxGroupTree, 'enable', val);
    set(handles.radiobuttonProcTypeGroup, 'enable', val);
    set(handles.radiobuttonProcTypeSubj, 'enable', val);
    set(handles.radiobuttonProcTypeRun, 'enable', val);
    set(handles.radiobuttonPlotRaw, 'enable', val);
    set(handles.radiobuttonPlotOD,  'enable', val);
    set(handles.radiobuttonPlotConc, 'enable', val);
    set(handles.checkboxPlotHRF, 'enable', val);
    set(handles.textStatus, 'enable', val);
    set(handles.listboxPlotConc, 'enable', val);
    % Plot window panel
    set(handles.pushbuttonPanLeft, 'enable', val);
    set(handles.pushbuttonPanRight, 'enable', val);
    set(handles.pushbuttonPanLeft, 'enable', val);
    set(handles.pushbuttonResetView, 'enable', val);
    set(handles.pushbuttonPanLeft, 'enable', val);
    set(handles.checkboxFixRangeX, 'enable', val);
    set(handles.editFixRangeX, 'enable', val);
    set(handles.checkboxFixRangeY, 'enable', val);
    set(handles.editFixRangeY, 'enable', val);
    % Motion artifact panel
    set(handles.checkboxShowExcludedTimeManual, 'enable', val);
    set(handles.checkboxShowExcludedTimeAuto, 'enable', val);
    set(handles.checkboxShowExcludedTimeAutoByChannel, 'enable', val);
    set(handles.checkboxExcludeTime, 'enable', val);
    % Control
    set(handles.pushbuttonCalcProcStream, 'enable', val);
    set(handles.pushbuttonProcStreamOptionsEdit, 'enable', val);
    set(handles.checkboxApplyProcStreamEditToAll, 'enable', val);
end