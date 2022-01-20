function InitCurrElem(guivar)
guivarstr = inputname(1);

eval(sprintf('global %s', guivarstr));

if isempty(eval(sprintf('%s.locDataTree', guivarstr)))
    eval(sprintf('%s.locDataTree = DataTreeClass({}, '''', '''', ''empty'');', guivarstr));
    eval(sprintf('%s.locDataTree.CopyCurrElem(%s.dataTree, ''reference'');', guivarstr, guivarstr));
else
    eval(sprintf('%s.locDataTree2 = DataTreeClass({}, '''', '''', ''empty'');', guivarstr));
    eval(sprintf('%s.locDataTree2.CopyCurrElem(%s.locDataTree, ''reference'');', guivarstr, guivarstr));
end
eval(sprintf('SyncBrowsing(%s, ''off'');', guivarstr, guivarstr));

