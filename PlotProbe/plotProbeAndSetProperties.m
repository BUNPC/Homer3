function plotProbeAndSetProperties(handles, iDataBlk)
global plotprobe

if ~exist('iDataBlk','var') || isempty(iDataBlk)
    iDataBlk=1;
end

y        = plotprobe.y{iDataBlk};
t        = plotprobe.t{iDataBlk};
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
tMarkAmp = plotprobe.tMarkAmp;
ch       = plotprobe.dataTree.currElem.GetMeasList(iDataBlk);
SD       = plotprobe.dataTree.currElem.GetSDG();

set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);
hData = plotProbe( y, t, SD, ch, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs(iDataBlk, hData);
plotprobe.handles.data = [plotprobe.handles.data; hData];
