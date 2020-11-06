function plotProbeAndSetProperties(handles, iBlk, iFig)
global plotprobe

if ~exist('iBlk','var') || isempty(iBlk)
    iBlk=1;
end
if ~exist('iFig','var') || isempty(iFig)
    iFig=1;
end

y        = plotprobe.y{iBlk};
t        = plotprobe.t{iBlk};
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
tMarkAmp = plotprobe.tMarkAmp;
ch       = plotprobe.dataTree.currElem(1).GetMeasList(iBlk);
SD       = plotprobe.dataTree.currElem(1).GetSDG();

set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);
hData = plotProbe( y, t, SD, ch, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs(iBlk, hData);
plotprobe.handles.data{iFig} = hData;
