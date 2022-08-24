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
   ystd  = plotprobe.ystd{iBlk};
else
   ystd  = [];
end

y        = plotprobe.y{iBlk};
ch.MeasList = plotprobe.dataTree.currElem.procStream.output.dcAvg.GetMeasurementList('matrix');
k = find(ch.MeasList(:,4) == 1);
ch.MeasList = ch.MeasList(k,:);
t        = plotprobe.t{iBlk};
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
tMarkAmp = plotprobe.tMarkAmp;
tMarkVis = plotprobe.tMarkShow;
SD       = plotprobe.dataTree.currElem.GetSDG('2D');

data = getappdata(handles.figure, 'data');
set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);
hData = plotProbe( y, t, SD, ch, ystd, axScl, tMarkInt, tMarkAmp, tMarkVis );
data{iFig} = hData;
setappdata(handles.figure, 'data',data);


