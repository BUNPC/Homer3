function UpdateCondPopupmenu(handles)
global maingui

if isempty(handles)
    return;
end
if isempty(maingui)
    return;
end
if maingui.dataTree.IsEmpty()
    return;
end

CondNames = maingui.dataTree.group.GetConditions();
CondNamesCurrElem = maingui.dataTree.currElem.GetConditionsActive();
for jj=1:length(CondNames)
    k = find(strcmp(['-- ', CondNames{jj}], CondNamesCurrElem));
    if ~isempty(k)
        CondNames{jj} = ['-- ', CondNames{jj}];
    end
end
set(handles.popupmenuConditions, 'string', CondNames);
maingui.condition = get(handles.popupmenuConditions, 'value');


