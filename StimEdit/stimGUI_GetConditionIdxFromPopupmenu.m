function [icond, conditions] = stimGUI_GetConditionIdxFromPopupmenu(conditions, handles)

conditions_menu = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
if isempty(conditions_menu)
    icond = 1;
    return;
end
condition = conditions_menu{idx};
icond = find(strcmp(conditions, condition));
if isempty(icond)
    icond = 1;
end
