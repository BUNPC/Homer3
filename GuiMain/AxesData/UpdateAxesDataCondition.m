function guiMain = UpdateAxesDataCondition(guiMain, dataTree)

CondNames = dataTree.group.GetConditions();
CondNamesCurrElem = dataTree.currElem.procElem.GetConditionsActive();
for jj=1:length(CondNames)
    k = find(strcmp(['-- ', CondNames{jj}], CondNamesCurrElem));
    if ~isempty(k)
        CondNames{jj} = ['-- ', CondNames{jj}];
    end
end
set(guiMain.handles.popupmenuConditions, 'string', CondNames);
guiMain.condition = getCondition(guiMain);
set(guiMain.handles.popupmenuConditions, 'value', guiMain.condition);


