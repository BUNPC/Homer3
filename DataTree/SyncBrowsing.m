function SyncBrowsing(guivar, onoff)
guivarstr = inputname(1);

eval(sprintf('global %s', guivarstr));

if isempty(eval(sprintf('%s.locDataTree2', guivarstr)))
    if strcmpi(onoff, 'off')
        eval(sprintf('%s.dataTreeHandle = %s.locDataTree;', guivarstr, guivarstr));
    else
        eval(sprintf('%s.dataTreeHandle = %s.dataTree;', guivarstr, guivarstr));
    end
else
    if strcmpi(onoff, 'off')
        eval(sprintf('%s.dataTreeHandle = %s.locDataTree2;', guivarstr, guivarstr));
    else
        eval(sprintf('%s.dataTreeHandle = %s.locDataTree;', guivarstr, guivarstr));
    end
end