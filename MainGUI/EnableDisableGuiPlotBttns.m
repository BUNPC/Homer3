function EnableDisableGuiPlotBttns(handles)
global maingui
if isempty(handles)
    return
end

if ~isempty(maingui.dataTree.currElem(1).GetRawData())   
    set(handles.radiobuttonPlotRaw, 'enable','on')
else
    set(handles.radiobuttonPlotRaw, 'enable','off')
end
if ~isempty(maingui.dataTree.currElem(1).GetDod())
    set(handles.radiobuttonPlotOD, 'enable','on')
else
    set(handles.radiobuttonPlotOD, 'enable','off')
end
if ~isempty(maingui.dataTree.currElem(1).GetDc())
    set(handles.radiobuttonPlotConc, 'enable','on')
else
    set(handles.radiobuttonPlotConc, 'enable','off')
end

raw_checked  = get(handles.radiobuttonPlotRaw, 'value');
OD_checked   = get(handles.radiobuttonPlotOD, 'value');
Conc_checked = get(handles.radiobuttonPlotConc, 'value');
if strcmp(get(handles.radiobuttonPlotRaw, 'enable'), 'on')
    raw_enable  = true;
else
    raw_enable  = false;
end
if strcmp(get(handles.radiobuttonPlotOD, 'enable'), 'on')
    OD_enable  = true;
else
    OD_enable  = false;
end
if strcmp(get(handles.radiobuttonPlotConc, 'enable'), 'on')
    Conc_enable  = true;
else
    Conc_enable  = false;
end

iCondGrp = get(handles.popupmenuConditions, 'value'); 
CondName = maingui.dataTree.groups(1).CondNames{iCondGrp};
if ~isempty(maingui.dataTree.currElem(1).GetDodAvg(CondName)) || ~isempty(maingui.dataTree.currElem(1).GetDcAvg(CondName))
    set(handles.checkboxPlotHRF, 'enable','on');
    if ~isa(maingui.dataTree.currElem, 'RunClass')
        set(handles.checkboxPlotHRF, 'value',1);
        if ~isempty(maingui.dataTree.currElem(1).GetDcAvg())
            set(handles.radiobuttonPlotConc, 'value',1);
        elseif ~isempty(maingui.dataTree.currElem(1).GetDodAvg())
            set(handles.radiobuttonPlotOD, 'value',1);
        end
    end
elseif raw_enable && raw_checked
    set(handles.checkboxPlotHRF, 'enable','off');
    set(handles.checkboxPlotHRF, 'value',0);
elseif ~OD_enable && ~Conc_enable
    set(handles.checkboxPlotHRF, 'enable','off');
    set(handles.checkboxPlotHRF, 'value',0);
else
    set(handles.checkboxPlotHRF, 'enable','off');
    set(handles.checkboxPlotHRF, 'value',0);    
end

if isa(maingui.dataTree.currElem, 'RunClass')
    if ~OD_enable && ~Conc_enable
        set(handles.radiobuttonPlotRaw, 'value',1)        
    end
end



