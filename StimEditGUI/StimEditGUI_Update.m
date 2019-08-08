function StimEditGUI_Update(handles)
global stimEdit

if ~exist('handles','var') || isempty(handles)
    return;
end
if ~ishandles(handles.figure)
    return;
end

conditions =  stimEdit.dataTree.currElem.GetConditions();
filename = stimEdit.dataTree.currElem.GetName();
[~, fname, ext] = fileparts(filename);
StimEditGUI_SetTextFilename([fname, ext, ' :'], handles);

% Try to keep the same condition as old run
[icond, conditions] = StimEditGUI_GetConditionIdxFromPopupmenu(conditions, handles);
set(handles.popupmenuConditions, 'value',icond);
set(handles.popupmenuConditions, 'string',conditions);
StimEditGUI_SetUitableStimInfo(conditions{icond}, handles);
StimEditGUI_Display(handles);
figure(handles.figure);

