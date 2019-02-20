function plotProbeAndSetProperties(handles)
global plotprobe

y        = plotprobe.y;
t        = plotprobe.t;
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
tMarkAmp = plotprobe.tMarkAmp;
ch       = plotprobe.dataTree.currElem.GetMeasList();
SD       = plotprobe.dataTree.currElem.GetSDG();


set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);
plotprobe.handles.data = plotProbe( y, t, SD, ch, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs();

