function PatchCallback(idx)
global maingui

h = zoom;
if strcmp(h.Enable,'on')
    return;
end
    
ch = MenuBox('Remove this Exclude Region?',{'Yes','No'});
if ch==2
    return
end

iCh = maingui.axesSDG.iCh;
iDataBlks =  maingui.dataTree.currElem(1).GetDataBlocksIdxs(iCh);
for iBlk=1:iDataBlks
    tInc = maingui.dataTree.currElem(1).GetTincMan(iBlk);
    t = maingui.dataTree.currElem(1).GetTime(iBlk);
    p = TimeExcludeRanges(tInc,t);
    lst = find(t>=p(idx,1) & t<=p(idx,2));
    maingui.dataTree.currElem(1).SetTincMan(lst, iBlk, 'include');

    % Unreject all stims that fall within the included time
    maingui.dataTree.currElem(1).StimInclude(t, iBlk);
end
maingui.Update('PatchCallback');


