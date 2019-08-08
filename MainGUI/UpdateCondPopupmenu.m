function UpdateCondPopupmenu(handles)
global hmr

if isempty(handles)
    return;
end
if isempty(hmr)
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
hmr.condition = get(handles.popupmenuConditions, 'value');


