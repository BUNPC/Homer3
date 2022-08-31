function plotProbeAndSetProperties(handles, iFig)
global plotprobe

if ~exist('iFig','var') || isempty(iFig)
    iFig = 1;
end

hold on

data = getappdata(handles.figure, 'data');
set(handles.textTimeMarkersAmpUnits, 'string',plotprobe.tMarkUnits);

axScl    = plotprobe.axScl;
tMarkInt = plotprobe.tMarkInt;
tMarkAmp = plotprobe.tMarkAmp;
tMarkVis = plotprobe.tMarkShow;

nDataBlks = plotprobe.dataTreeHandle.currElem.GetDataBlocksNum();
plotprobe.y = cell(nDataBlks,1);
plotprobe.t = cell(nDataBlks,1);
hData = [];
for iBlk = 1:nDataBlks
    updateData(handles, iBlk);
    
    y        = plotprobe.y{iBlk};
    ml       = plotprobe.ml{iBlk};
    t        = plotprobe.t{iBlk};
    ystd     = plotprobe.ystd{iBlk};
    SD       = plotprobe.SD;
    
    h = plotProbe( y, t, SD, ml, ystd, axScl, tMarkInt, tMarkAmp, tMarkVis );
    hData = [hData; h];
end
data{iFig} = hData;
setappdata(handles.figure, 'data',data);
hold off


% -------------------------------------------------------------------------
function updateData(handles, iBlk)
global plotprobe
plotprobe.tMarkAmp = str2num(get(handles.editPlotProbeTimeMarkersAmp, 'string'));

if plotprobe.datatype == plotprobe.datatypeVals.OD_HRF
    plotprobe.y{iBlk} = plotprobe.dataTree.currElem.procStream.output.dodAvg(iBlk).GetDataTimeSeries();
    plotprobe.ml{iBlk} = plotprobe.dataTree.currElem.procStream.output.dodAvg(iBlk).GetMeasurementList('matrix');
    if handles.radiobuttonShowStd.Value
        plotprobe.ystd{iBlk} = plotprobe.dataTree.currElem.procStream.output.dodAvgStd(iBlk).GetDataTimeSeries();
    else
        plotprobe.ystd{iBlk} = [];
    end
    plotprobe.t{iBlk} = plotprobe.dataTree.currElem.procStream.output.dodAvg(iBlk).GetTime();
    plotprobe.tMarkUnits = '(AU)';
elseif plotprobe.datatype == plotprobe.datatypeVals.CONC_HRF
    plotprobe.y{iBlk} = plotprobe.dataTree.currElem.procStream.output.dcAvg(iBlk).GetDataTimeSeries();
    plotprobe.ml{iBlk} = plotprobe.dataTree.currElem.procStream.output.dcAvg(iBlk).GetMeasurementList('matrix');
    if handles.radiobuttonShowStd.Value
        plotprobe.ystd{iBlk} = plotprobe.dataTree.currElem.procStream.output.dcAvgStd(iBlk).GetDataTimeSeries();
    else
        plotprobe.ystd{iBlk} = [];
    end
    plotprobe.t{iBlk} = plotprobe.dataTree.currElem.procStream.output.dcAvg(iBlk).GetTime();
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
    plotprobe.tMarkUnits = '(micro-molars)';
elseif plotprobe.datatype == plotprobe.datatypeVals.CONC
    plotprobe.y{iBlk} = plotprobe.dataTree.currElem.procStream.output.dc(iBlk).GetDataTimeSeries();
    plotprobe.ml{iBlk} = plotprobe.dataTree.currElem.procStream.output.dc(iBlk).GetMeasurementList('matrix');
    plotprobe.ystd{iBlk} = [];
    plotprobe.t{iBlk} = plotprobe.dataTree.currElem.procStream.output.dc(iBlk).GetTime();
elseif plotprobe.datatype == plotprobe.datatypeVals.OD
    plotprobe.y{iBlk} = plotprobe.dataTree.currElem.procStream.output.dod(iBlk).GetDataTimeSeries();
    plotprobe.ml{iBlk} = plotprobe.dataTree.currElem.procStream.output.dod(iBlk).GetMeasurementList('matrix');
    plotprobe.ystd{iBlk} = [];
    plotprobe.t{iBlk} = plotprobe.dataTree.currElem.procStream.output.dod(iBlk).GetTime();
elseif plotprobe.datatype == plotprobe.datatypeVals.RAW
    plotprobe.y{iBlk} = plotprobe.dataTree.currElem.acquired.data(iBlk).GetDataTimeSeries();
    plotprobe.ml{iBlk} = plotprobe.dataTree.currElem.acquired.data(iBlk).GetMeasurementList('matrix');
    plotprobe.ystd{iBlk} = [];
    plotprobe.t{iBlk} = plotprobe.dataTree.currElem.acquired.data(iBlk).GetTime();
else
    plotprobe.y{iBlk} = [];
    plotprobe.ml{iBlk} = [];
    plotprobe.ystd{iBlk} = [];
    plotprobe.t{iBlk} = [];    
end

% Apply condition to isolate data to be displayed
if ~isempty(plotprobe.y{iBlk})
    k = find(plotprobe.ml{iBlk}(:,3) == plotprobe.condition);
    if isempty(k)
        k = 1:size(plotprobe.ml{iBlk},1);
    end
    if ~isempty(plotprobe.y{iBlk})
        plotprobe.y{iBlk} = plotprobe.y{iBlk}(:,k);
    end
    if ~isempty(plotprobe.ystd{iBlk})
        plotprobe.ystd{iBlk} = plotprobe.ystd{iBlk}(:,k);
    end
    if ~isempty(plotprobe.ml{iBlk})
        plotprobe.ml{iBlk} = plotprobe.ml{iBlk}(k,:);
    end
end

% Get probe
plotprobe.SD = plotprobe.dataTree.currElem.GetSDG('2D');



