function LoadRunPlotExample2(dataSetDir)

%
%   Syntax:
%       LoadRunPlotExample2(dataSetDir)
%
%   Description:
%       This script does the following:
%
%       1. If starting from scratch, first download the DataTree repo from
%          github
%
%           a) git clone  -b <branch_name>   https://github.com/<username>/DataTree  <local_path>/DataTree
%           b) cd <local_path>/DataTree
%           c) setpaths
%
%       2. Change folder to dataSetDir (1st arg)
%       3. Load data set
%       4. Plot raw data for various dataTree elements
%       5. Run processing stream
%       6. Plot HRF for various dataTree elements
%
%   Examples:
%       cd <local_path>/DataTree
%       LoadRunPlotExample2('./Examples/Example4_twNI')
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dataSetDir','var')
    f = which('LoadRunPlotExample2');
    dataSetDir = [fileparts(f), '/Example4_twNI'];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a) Change current folder to a data set folder,
% b) Load dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(dataSetDir,'dir')
    mkdir(dataSetDir);
end
cd(dataSetDir)
if exist([dataSetDir, '/derivatives']','dir')
    rmdir([dataSetDir, '/derivatives'], 's')
end
dataTree = DataTreeClass();
if dataTree.IsEmpty()
    MenuBox('No data set was loaded', 'OK');
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for current element, for  1st wavelength of 3 source/detector pairs , [2,3], [3,5] and [4,6]:
% (NOTE: for non-HRF, raw, and OD, condition is 0 and datatype refers to wavelength)
%        for non-HRF, concentration, condition is 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 0,   datatype idx = 1
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 0,   datatype idx = 1
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 0,   datatype idx = 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Load();

[time, dataTimeSeries, measurementList, stim, probe] = GetAcquiredData(obj);
sdPairsSelect = [2,3,0,1; 3,5,0,1; 4,6,0,1];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
plotname = sprintf('"%s" (%s);   raw data', obj.GetName(), num2str([obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]));
h(1,:) = Plot(time, dataTimeSeries, measurementList, stim, probe, sdPairsSelect, plotname);
repositionFigures(h);
pause(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for 3rd run of the 1st session, 3rd subject, 1st group,  
% for 2nd wavelength of 3 source/detector pairs, [2,3], [3,5] and [4,6]:
% (NOTE: for non-HRF, raw, and OD, condition is 0 and datatype refers to wavelength)
%        for non-HRF, concentration, condition is 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 0,   datatype idx = 2
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 0,   datatype idx = 2
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 0,   datatype idx = 2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1).subjs(2).sess(1).runs(3);
obj.Load();

[time, dataTimeSeries, measurementList, stim, probe] = GetAcquiredData(obj);
sdPairsSelect = [2,3,0,2; 3,5,0,2; 4,6,0,2];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
plotname = sprintf('"%s" (%s);   raw data', obj.GetName(), num2str([obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]));
h(2,:) = Plot(time, dataTimeSeries, measurementList, stim, probe, sdPairsSelect, plotname);
repositionFigures(h);
pause(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for current element and plot concentration HRF for HbR of condition 1,
% for 3 channels with source/detector pairs, [2,3], [3,5] and [4,6]:
%
% (NOTE: for HRF data OD, condition is > 0 and datatype refers to wavelength)
%        for HRF data concentration, condition is > 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 1,   datatype idx = 2
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 1,   datatype idx = 2
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 1,   datatype idx = 2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Calc();

[time, dataTimeSeries, measurementList, stim, probe] = GetDerivedData(obj, 'conc hrf');
sdPairsSelect = [2,3,1,2; 3,5,1,2; 4,6,1,2];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
plotname = sprintf('"%s" (%s);   conc hrf', obj.GetName(), num2str([obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]));
h(3,:) = Plot(time, dataTimeSeries, measurementList, stim, probe, sdPairsSelect, plotname);
repositionFigures(h);
pause(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for group 1 and plot concentration HRF for HbT of condition 2,
% for 2 channels with source/detector pairs, [3,6] and [4,8]:
%
% (NOTE: for HRF data OD, condition is > 0 and datatype refers to wavelength)
%        for HRF data concentration, condition is > 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 3, detector idx = 6,  condition idx = 2,   datatype idx = 3
%    ch B:      source idx = 4, detector idx = 8,  condition idx = 2,   datatype idx = 3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1);
obj.Calc();

[time, dataTimeSeries, measurementList, stim, probe] = GetDerivedData(obj, 'conc hrf');
sdPairsSelect = [3,6,2,3; 4,8,2,3];     % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
plotname = sprintf('"%s" (%s);   conc hrf', obj.GetName(), num2str([obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]));
h(4,:) = Plot(time, dataTimeSeries, measurementList, stim, probe, sdPairsSelect, plotname);
repositionFigures(h);
pause(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close open log files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.logger.Close();
MenuBox('When done, click okay button to close all plots', 'OK');
for ii = 1:length(h(:))
    if ishandles(h(ii))
        close(h(ii))
    end
end



% -------------------------------------------------------------------
function [time, dataTimeSeries, measurementList, stim, probe] = GetAcquiredData(obj)
snirfObj = obj.acquired;

time            = snirfObj.data(1).time;
dataTimeSeries  = snirfObj.data(1).dataTimeSeries;
measurementList = snirfObj.data(1).measurementList;
stim            = snirfObj.stim;
probe           = snirfObj.probe;



% -------------------------------------------------------------------
function [time, dataTimeSeries, measurementList, stim, probe] = GetDerivedData(obj, datatype)

% Get probe and stim from derived input 
probe  = obj.GetProbe();
if ~isempty(obj.procStream.input.acquired)
    stim   = obj.procStream.input.acquired.stim;
else
    stim = [];
end

% Get data from derived output 
switch(lower(datatype))
    case 'od'
        data       = obj.procStream.output.dod;
    case 'conc'
        data       = obj.procStream.output.dod;
    case 'od hrf'
        data       = obj.procStream.output.dodAvg;
    case 'conc hrf'
        data       = obj.procStream.output.dcAvg;
end
time            = data(1).time;
dataTimeSeries  = data(1).dataTimeSeries;
measurementList = data(1).measurementList;



% -------------------------------------------------------------------
function hFig = Plot(time, dataTimeSeries, measurementList, stim, probe, sdPairs, plotname)
if isempty(dataTimeSeries)
    fprintf('No data to plot\n');
    return;
end

ml = ConvertMeasurementListToMatrix(measurementList);

% Convert channels specified by SD pairs to single number vector containing channel indices into the measurement list
iChs = [];
for kk = 1:size(sdPairs,1)
    ii = find( (ml(:,1)==sdPairs(kk,1)) & (ml(:,2)==sdPairs(kk,2)) & (ml(:,3)==sdPairs(kk,3)) & (ml(:,4)==sdPairs(kk,4)));
    if isempty(ii)
        continue;
    end
    iChs = [iChs; ii];
end

% Create figure for plotting
plotname = sprintf('%s ;  channels idxs: [%s]', plotname, num2str(iChs'));
hFig(1) = figure('menubar','none', 'NumberTitle','off', 'name',plotname);
hAxes = gca;


% Plot data
hold on
chSelect = [];
for ii = 1:length(iChs)
    hdata(ii) = plot(hAxes, time, dataTimeSeries(:,iChs(ii)), 'linewidth',2);
    chSelect(ii,:) = [ml(iChs(ii),1), ml(iChs(ii),2), ml(iChs(ii),3), ml(iChs(ii),4), get(hdata(ii), 'color')];
end
set(hAxes, 'xlim', [time(1), time(end)]);

% Plot stim
if ~isempty(stim)
    CondNames = {};
    hCond = [];
    iCond = [];
    kk = 1;    
    ylim = get(hAxes, 'ylim');
    d = (1e-4)*(ylim(2)-ylim(1));
    yrange = [ylim(1)+d, ylim(2)-d];
    stimColorsTable = [1.0,0.0,0.0; 0.0,1.0,0.0; 0.0,0.0,1.0; 1.0,1.0,0.0; 1.0,0.0,1.0; 0.0,1.0,1.0; 1.0,0.5,0.0; 1.0,0.0,0.5; 0.5,1.0,0.0; 0.5,0.0,1.0];
    for jj = 1:length(stim)
        h = [];
        for ii = 1:size(stim(jj).data,1)
            if isempty(stim(jj).data)
                continue
            end
            h = plot(hAxes, stim(jj).data(ii,1)*[1,1], yrange, 'color',stimColorsTable(jj,:));
        end
        CondNames{jj} = stim(jj).name;
        if ~isempty(h)
            hCond(kk) = h;
            iCond(kk) = jj;
            kk = kk+1;
        end
    end
    if ishandles(hCond)
        legend(hAxes, hCond, CondNames(iCond));
    end
end

% Display probe in separate figure
if isempty(chSelect)
    fprintf('ERROR: no valid channels were selelcted');
    hFig(2) = DisplayProbe(probe, sdPairs);
else
    hFig(2) = DisplayProbe(probe, chSelect(:,1:2), chSelect(:,5:7), ml, plotname);
end

% Wrap up before exiting
drawnow;
pause(.1);
hold off



% -------------------------------------------------------------------
function hFig = DisplayProbe(probe, chSelect, chSelectColors, ml, plotname)
% Parse args
if ~exist('chSelect','var')
    chSelect = [];
end
if ~exist('chSelectColors','var')
    chSelectColors = repmat([1.0, 0.5, 0.2], size(chSelect,1),1);
end

% Set up the axes
bbox = probe.GetSdgBbox();
    
% See if there's a data plot associated with this probe display
% If there is get its name and use it to name this figure
hFig = figure('menubar','none', 'NumberTitle','off', 'name',plotname);
hAxes = gca;

axis(hAxes, [bbox(1), bbox(2), bbox(3), bbox(4)]);
gridsize = get(hAxes, {'xlim', 'ylim', 'zlim'});
if ismac() || islinux()
    fs = 18;
else
    fs = 11;
end

% Get probe paramaters
srcpos = probe.sourcePos2D;
detpos = probe.detectorPos2D;
lstSDPairs = find(ml(:,4)==1);

% Draw all channels
for ii = 1:length(lstSDPairs)
    hCh(ii) = line2(srcpos(ml(lstSDPairs(ii),1),:), detpos(ml(lstSDPairs(ii),2),:), [], gridsize, hAxes);
    col = [1.00 1.00 1.00] * 0.85;
    if ~isempty(chSelect)
        k = find(chSelect(:,1)==ml(lstSDPairs(ii),1) & chSelect(:,2)==ml(lstSDPairs(ii),2));
        if ~isempty(k)
            col = chSelectColors(k(1),:);
        end
    end
    set(hCh(ii), 'color',col, 'linewidth',2, 'linestyle','-', 'userdata',ml(lstSDPairs(ii),1:2));
end

% ADD SOURCE AND DETECTOR LABELS
for iSrc = 1:size(srcpos,1)
    if ~isempty(find(ml(:,1)==iSrc)) %#ok<*EFIND>
        hSD(iSrc) = text( srcpos(iSrc,1), srcpos(iSrc,2), sprintf('%d', iSrc), 'fontsize',fs, 'fontweight','bold', 'color','r' );
        set(hSD(iSrc), 'horizontalalignment','center', 'edgecolor','none', 'Clipping', 'on');
    end
end
for iDet = 1:size(detpos,1)
    if ~isempty(find(ml(:,2)==iDet))
        hSD(iDet+iSrc) = text( detpos(iDet,1), detpos(iDet,2), sprintf('%d', iDet), 'fontsize',fs, 'fontweight','bold', 'color','b' );
        set(hSD(iDet+iSrc), 'horizontalalignment','center', 'edgecolor','none', 'Clipping', 'on');
    end
end



% ---------------------------------------------------------
function ml = ConvertMeasurementListToMatrix(measurementList)
ml = zeros(length(measurementList),4);
hbTypes = {'hbo','hbr','hbt'};
for ii = 1:length(measurementList)
    k = 0;
    for jj = 1:length(hbTypes)
        if ~isempty(strfind(lower(measurementList(ii).dataTypeLabel), hbTypes{jj}))
            k = jj;
            break;
        end
    end
    if measurementList(ii).wavelengthIndex > 0
        ml(ii,:) = [measurementList(ii).sourceIndex, measurementList(ii).detectorIndex, measurementList(ii).dataTypeIndex, measurementList(ii).wavelengthIndex];
    elseif k > 0
        ml(ii,:) = [measurementList(ii).sourceIndex, measurementList(ii).detectorIndex, measurementList(ii).dataTypeIndex, k];
    end
end



% -------------------------------------------------------------------
function repositionFigures(h)
n = size(h,1);
set(h(n,1), 'units','normalized')
set(h(n,2), 'units','normalized')
p1 = get(h(n,1), 'position');
p2 = get(h(n,2), 'position');
set(h(n,1), 'position',[p1(1)-(p1(1)/2),  1.0-(p1(4)+n/10),  p1(3),  p1(4)])
set(h(n,2), 'position',[p2(1)+(p2(1)/2),  1.0-(p2(4)+n/10),  p2(3),  p2(4)])



