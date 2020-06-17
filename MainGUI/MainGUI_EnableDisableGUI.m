function MainGUI_EnableDisableGUI(val)
    global maingui;
    set(maingui.handles.listboxGroupTree, 'enable', val);
    set(maingui.handles.radiobuttonProcTypeGroup, 'enable', val);
    set(maingui.handles.radiobuttonProcTypeSubj, 'enable', val);
    set(maingui.handles.radiobuttonProcTypeRun, 'enable', val);
    set(maingui.handles.radiobuttonPlotRaw, 'enable', val);
    set(maingui.handles.radiobuttonPlotOD,  'enable', val);
    set(maingui.handles.radiobuttonPlotConc, 'enable', val);
    set(maingui.handles.checkboxPlotHRF, 'enable', val);
    set(maingui.handles.textStatus, 'enable', val);
    set(maingui.handles.listboxPlotConc, 'enable', val);
    % Plot window panel
    set(maingui.handles.pushbuttonPanLeft, 'enable', val);
    set(maingui.handles.pushbuttonPanRight, 'enable', val);
    set(maingui.handles.pushbuttonPanLeft, 'enable', val);
    set(maingui.handles.pushbuttonResetView, 'enable', val);
    set(maingui.handles.pushbuttonPanLeft, 'enable', val);
    set(maingui.handles.checkboxFixRangeX, 'enable', val);
    set(maingui.handles.editFixRangeX, 'enable', val);
    set(maingui.handles.checkboxFixRangeY, 'enable', val);
    set(maingui.handles.editFixRangeY, 'enable', val);
    % Motion artifact panel
    set(maingui.handles.checkboxShowExcludedTimeManual, 'enable', val);
    set(maingui.handles.checkboxShowExcludedTimeAuto, 'enable', val);
    set(maingui.handles.checkboxShowExcludedTimeAutoByChannel, 'enable', val);
    set(maingui.handles.checkboxExcludeTime, 'enable', val);
    % Control
    set(maingui.handles.pushbuttonCalcProcStream, 'enable', val);
    set(maingui.handles.pushbuttonProcStreamOptionsEdit, 'enable', val);
    set(maingui.handles.checkboxApplyProcStreamEditToAll, 'enable', val);
end