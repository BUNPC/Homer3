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

plotprobe.dataTypeWarning.datatype = '';

d = [];
if plotprobe.datatype == plotprobe.datatypeVals.OD_HRF
    d = plotprobe.dataTree.currElem.procStream.output.dodAvg;
    plotprobe.tMarkUnits = '(AU)';
elseif plotprobe.datatype == plotprobe.datatypeVals.CONC_HRF
    d = plotprobe.dataTree.currElem.procStream.output.dcAvg;
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
    plotprobe.tMarkUnits = '(micro-molars)';
elseif plotprobe.datatype == plotprobe.datatypeVals.CONC
    d = plotprobe.dataTree.currElem.procStream.output.dc;
    plotprobe.dataTypeWarning.datatype = 'concentration';
elseif plotprobe.datatype == plotprobe.datatypeVals.OD
    d = plotprobe.dataTree.currElem.procStream.output.dod;
    plotprobe.dataTypeWarning.datatype = 'optical density';
elseif plotprobe.datatype == plotprobe.datatypeVals.RAW
    if ~isempty(plotprobe.dataTree.currElem.acquired)
        d = plotprobe.dataTree.currElem.acquired.data;
        plotprobe.dataTypeWarning.datatype = 'raw';
    end
end

if isempty(d)    
    plotprobe.y{1}       = [];
    plotprobe.ml{1}      = [];
    plotprobe.ystd{1}    = [];
    plotprobe.t{1}       = [];
else
    for ii = 1:length(d)
        plotprobe.y{iBlk}       = d(iBlk).GetDataTimeSeries();
        plotprobe.ml{iBlk}      = [d(iBlk).GetMeasurementList('matrix'), ones(size(plotprobe.y{iBlk},2))];
        if handles.radiobuttonShowStd.Value
            plotprobe.ystd{iBlk} = d(iBlk).GetDataTimeSeries();
        else
            plotprobe.ystd{iBlk} = [];
        end
        plotprobe.t{iBlk}       = d(iBlk).GetTime();
        
        initActiveChannels(iBlk, d);
    end
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

% Give warning if plot is non-HRF time course data
displayDataTypeWarnings();



% -------------------------------------------------------------
function mlAct = initActiveChannels(iBlk, d)
global plotprobe
mlAct = [];

mlActAuto = plotprobe.dataTree.currElem.GetVar('mlActAuto');
mlActMan = plotprobe.dataTree.currElem.GetVar('mlActMan');

if isempty(mlActMan)
    mlActMan = cell(length(d),1);
end
if isempty(mlActAuto)
    mlActAuto = cell(length(d),1);
end

ml0 = plotprobe.dataTree.currElem.GetMeasurementList('matrix', iBlk, 'od');
if isempty(ml0)
    return;
end
mlActAutoMatrix = mlAct_Initialize(mlActAuto{iBlk}, ml0);
mlActManMatrix = mlAct_Initialize(mlActMan{iBlk}, ml0);
mlActAutoVector = mlAct_Matrix2BinaryVector(mlActAutoMatrix, plotprobe.ml{iBlk});
mlActManVector = mlAct_Matrix2BinaryVector(mlActManMatrix, plotprobe.ml{iBlk});
mlAct = mlActAutoVector & mlActManVector;
if isempty(mlAct)
    return;
end
plotprobe.ml{iBlk}(:,5) = mlAct;



% -------------------------------------------------------------
function displayDataTypeWarnings()
global plotprobe
if ~isempty(plotprobe.dataTypeWarning.datatype) &&  (plotprobe.dataTypeWarning.selection(2) == false)
    msg{1} = sprintf('WARNING: You have selected %s to view in PlotProbeGUI, a non-HRF time course data (PlotProbeGUI will display this data). ', plotprobe.dataTypeWarning.datatype);
    msg{2} = sprintf('To view HRF data please check the HRF option in the "Plot Type Select" or similar panel in the parent GUI');
    plotprobe.dataTypeWarning.selection = MenuBox(msg, 'OK', [], [], plotprobe.dataTypeWarning.menuboxoption);
end



