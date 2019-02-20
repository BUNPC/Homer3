function guiControls = UpdateAxesDataCondition(guiControls, dataTree)
global hmr
if nargin==0
    guiControls = hmr.guiControls;
    dataTree = hmr.dataTree;
end

if isempty(guiControls)
    return;
end
if dataTree.IsEmpty()
    return;
end

CondNames = dataTree.group.GetConditions();
CondNamesCurrElem = dataTree.currElem.GetConditionsActive();
for jj=1:length(CondNames)
    k = find(strcmp(['-- ', CondNames{jj}], CondNamesCurrElem));
    if ~isempty(k)
        CondNames{jj} = ['-- ', CondNames{jj}];
    end
end
set(guiControls.handles.popupmenuConditions, 'string', CondNames);
guiControls.condition = get(guiControls.handles.popupmenuConditions, 'value');
set(guiControls.handles.popupmenuConditions, 'value', guiControls.condition);

if nargin==0
    hmr.guiControls = guiControls;
end
