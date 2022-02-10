function [viewSetting, views] = SetView(handles, nSubjs, nSess, nRuns)
global maingui

if nSess == nRuns
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','on');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
else
    set(handles.menuItemGroupViewSettingGroup,'checked','on');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end

if strcmp(get(handles.menuItemGroupViewSettingGroup,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.GROUP;
elseif strcmp(get(handles.menuItemGroupViewSettingSubjects,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.SUBJS;
elseif strcmp(get(handles.menuItemGroupViewSettingSessions,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.SESS;
elseif strcmp(get(handles.menuItemGroupViewSettingNoSessions,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.NOSESS;
elseif strcmp(get(handles.menuItemGroupViewSettingRuns,'checked'),'on')
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.RUNS;
else
    maingui.listboxGroupTreeParams.viewSetting = maingui.listboxGroupTreeParams.views.GROUP;
end

viewSetting = maingui.listboxGroupTreeParams.viewSetting;
views = maingui.listboxGroupTreeParams.views;

