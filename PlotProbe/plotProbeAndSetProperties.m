function plotprobe = plotProbeAndSetProperties(plotprobe)

y        = plotprobe.y;
tHRF     = plotprobe.tHRF;
SD       = plotprobe.SD;
tMarkInt = plotprobe.tMarkInt;
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
bit0     = plotprobe.tMarkShow;
bit1     = plotprobe.hidMeasShow;
tMarkAmp = plotprobe.tMarkAmp;
hFig     = plotprobe.objs.Figure.h;

[hData, hFig, tMarkAmp] = plotProbe( y, tHRF, SD, hFig, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs( 2*bit1+bit0, SD, y, hData );

plotprobe.tMarkAmp = tMarkAmp;
plotprobe.objs.Data.h = hData;
plotprobe.objs.Figure.h = hFig;
