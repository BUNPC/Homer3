function [viewSetting, views] = SetView(handles, nSubjs, nRuns)
global hmr

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
    hmr.listboxGroupTreeParams.viewSetting = hmr.listboxGroupTreeParams.views.ALL;
elseif strcmp(get(handles.menuItemGroupViewSettingSubjects,'checked'),'on')
    hmr.listboxGroupTreeParams.viewSetting = hmr.listboxGroupTreeParams.views.SUBJS;
elseif strcmp(get(handles.menuItemGroupViewSettingRuns,'checked'),'on')
    hmr.listboxGroupTreeParams.viewSetting = hmr.listboxGroupTreeParams.views.RUNS;
else
    hmr.listboxGroupTreeParams.viewSetting = hmr.listboxGroupTreeParams.views.ALL;
end

viewSetting = hmr.listboxGroupTreeParams.viewSetting;
views = hmr.listboxGroupTreeParams.views;