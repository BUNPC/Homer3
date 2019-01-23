function stimGUI_Update(handles)
global stimEdit

if ~exist('handles','var') || isempty(handles)
    return;
end

conditions =  stimEdit.GetConditions();
filename = stimEdit.GetName();
[~, fname, ext] = fileparts(filename);
stimGUI_SetTextFilename([fname, ext, ' :'], handles);

% Try to keep the same condition as old run
[icond, conditions] = stimGUI_GetConditionIdxFromPopupmenu(conditions, handles);
set(handles.popupmenuConditions, 'value',icond);
set(handles.popupmenuConditions, 'string',conditions);
stimGUI_SetUitableStimInfo(conditions{icond}, handles);

