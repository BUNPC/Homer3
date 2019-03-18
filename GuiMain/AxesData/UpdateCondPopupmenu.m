function UpdateCondPopupmenu(handles)
global hmr

if isempty(handles)
    return;
end
if isempty(hmr.guiControls)
    return;
end
if hmr.dataTree.IsEmpty()
    return;
end

CondNames = hmr.dataTree.group.GetConditions();
CondNamesCurrElem = hmr.dataTree.currElem.GetConditionsActive();
for jj=1:length(CondNames)
    k = find(strcmp(['-- ', CondNames{jj}], CondNamesCurrElem));
    if ~isempty(k)
        CondNames{jj} = ['-- ', CondNames{jj}];
    end
end
set(handles.popupmenuConditions, 'string', CondNames);
hmr.guiControls.condition = get(handles.popupmenuConditions, 'value');
set(handles.popupmenuConditions, 'value', hmr.guiControls.condition);


