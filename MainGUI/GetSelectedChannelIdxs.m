function iCh = GetSelectedChannelIdxs()
global maingui

iCh = [];

iSrcDet  = maingui.axesSDG.iSrcDet;
nDataBlks = maingui.dataTree.currElem.GetDataBlocksNum();
ml = [];
for iBlk = 1:nDataBlks
    ch = maingui.dataTree.currElem.GetMeasList(iBlk);
    ml = [ml; ch.MeasList];
end
for ii = 1:size(iSrcDet,1)
    k = find(ml(:,1)==iSrcDet(ii,1) & ml(:,2)==iSrcDet(ii,2));
    if isempty(k)
        continue
    end
    iCh(end+1) = k(1);
end

