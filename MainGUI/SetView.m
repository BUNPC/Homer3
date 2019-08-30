function [viewSetting, views] = SetView(handles, nSubjs, nRuns)
global maingui

if nSubjs==nRuns
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','on');
else
    set(handles.menuItemGroupViewSettingGroup,'checked','on');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end

if strcmp(get(handles.menuItemGroupViewSettingGroup,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.GROUP;
elseif strcmp(get(handles.menuItemGroupViewSettingSubjects,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.SUBJS;
elseif strcmp(get(handles.menuItemGroupViewSettingRuns,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.RUNS;
else
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.GROUP;
end

viewSetting = maingui.listboxGroupTreeParams.viewSetting;
views = maingui.listboxGroupTreeParams.views;