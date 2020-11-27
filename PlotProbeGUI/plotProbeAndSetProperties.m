function plotProbeAndSetProperties(handles, iBlk, iFig)
global plotprobe

if ~exist('iBlk','var') || isempty(iBlk)
    iBlk=1;
end
if ~exist('iFig','var') || isempty(iFig)
    iFig=1;
end

% If checkbox is checked, display std
if handles.radiobuttonShowStd.Value & isfield(plotprobe, 'ystd')
   ystd  = plotprobe.ystd{iBlk} ./ sqrt(plotprobe.dataTree.currElem.GetNtrials(iBlk)); 
else
   ystd  = [];
end

y        = plotprobe.y{iBlk};
t        = plotprobe.t{iBlk};
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
tMarkAmp = plotprobe.tMarkAmp;
tMarkVis = plotprobe.tMarkShow;
ch       = plotprobe.dataTree.currElem.GetMeasList(iBlk);
SD       = plotprobe.dataTree.currElem.GetSDG();


set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);
hData = plotProbe( y, t, SD, ch, ystd, axScl, tMarkInt, tMarkAmp, tMarkVis );
plotprobe.handles.data{iFig} = hData;
