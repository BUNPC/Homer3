function [viewSetting, views] = SetView(handles, nSubjs, nRuns)
global maingui

if nSubjs==nRuns
    set(handles.menuItemGroupViewSettingAll,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','on');
else
    set(handles.menuItemGroupViewSettingAll,'checked','on');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end

if strcmp(get(handles.menuItemGroupViewSettingAll,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.ALL;
elseif strcmp(get(handles.menuItemGroupViewSettingSubjects,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.SUBJS;
elseif strcmp(get(handles.menuItemGroupViewSettingRuns,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.RUNS;
else
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.ALL;
end

viewSetting = maingui.listboxGroupTreeParams.viewSetting;
views = maingui.listboxGroupTreeParams.views;