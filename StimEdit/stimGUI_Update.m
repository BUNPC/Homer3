function stimGUI_Update(handles)
global stimEdit

if ~exist('handles','var') || isempty(handles)
    return;
end
if ~ishandles(handles.figure)
    return;
end

conditions =  stimEdit.dataTree.currElem.procElem.GetConditions();
filename = stimEdit.dataTree.currElem.procElem.GetName();
[~, fname, ext] = fileparts(filename);
stimGUI_SetTextFilename([fname, ext, ' :'], handles);

% Try to keep the same condition as old run
[icond, conditions] = stimGUI_GetConditionIdxFromPopupmenu(conditions, handles);
set(handles.popupmenuConditions, 'value',icond);
set(handles.popupmenuConditions, 'string',conditions);
stimGUI_SetUitableStimInfo(conditions{icond}, handles);
stimGUI_Display(handles);
figure(handles.figure);

