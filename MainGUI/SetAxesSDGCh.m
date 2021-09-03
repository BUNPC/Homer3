function SetAxesSDGCh(handles, eventdata)
global maingui

if ~exist('eventdata','var')
    eventdata = [];
end

hAxesSDG = handles.axesSDG;
iCh      = maingui.axesSDG.iCh;
iSrcDet  = maingui.axesSDG.iSrcDet;
SD       = maingui.dataTree.currElem.GetSDG('2D');

% Create measurement list which is concatenation of each data block's list
nDataBlks = maingui.dataTree.currElem.GetDataBlocksNum();
ml = [];
for iBlk = 1:nDataBlks
    ch = maingui.dataTree.currElem.GetMeasList(iBlk);
    ml = [ml; ch.MeasList];
end

% Maximum number of channels that can be selected simultaneously
maxCh    = size(maingui.axesSDG.linecolor,1);

h = hAxesSDG;
while ~strcmpi(get(h,'type'),'figure')
    h = get(h,'parent');
end
mouseevent = get(h,'selectiontype');
if strcmp(mouseevent,'extend') && nDataBlks>1
    MessageBox('Warning: Extended channel selection has not yet been implemented for data with multiple data blocks.', ...
               'Not Yet Implemented')
    return;
end

pos = GetAxesSDGCurrentPoint(handles, eventdata);

% Find the closest optode
rmin = ( (pos(1,1)-SD.SrcPos(1,1))^2 + (pos(1,2)-SD.SrcPos(1,2))^2 )^0.5 ;
idxMin = 1;
SrcMin = 1;
for idx=1:size(SD.SrcPos,1)
    ropt = ( (pos(1,1)-SD.SrcPos(idx,1))^2 + (pos(1,2)-SD.SrcPos(idx,2))^2 )^0.5 ;
    if ropt<rmin
        idxMin = idx;
        rmin = ropt;
    end
end
for idx=1:size(SD.DetPos,1)
    ropt = ( (pos(1,1)-SD.DetPos(idx,1))^2 + (pos(1,2)-SD.DetPos(idx,2))^2 )^0.5 ;
    if ropt<rmin
        idxMin = idx;
        SrcMin = 0;
        rmin = ropt;
    end
end

if SrcMin
    lst = find(ml(:,1) == idxMin);
else
    lst = find(ml(:,2) == idxMin); 
end

% Remove any channels from lst which are already part of iCh
% to avoid confusion with double counting of channels
lst(ismember(lst, iCh)) = [];
if strcmp(mouseevent,'normal')
    if SrcMin
        iCh = lst;
        iSrcDet = [idxMin*ones(length(lst),1) ml(lst,2)];
    else
        iCh = lst;
        iSrcDet = [ml(lst,1) idxMin*ones(length(lst),1)];
    end
elseif strcmp(mouseevent,'extend')
    if SrcMin
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [idxMin*ones(length(lst),1) ml(lst,2)];
    else
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [ml(lst,1) idxMin*ones(length(lst),1)];
    end
end

% Set indices of displayed channels
maingui.axesSDG.iCh     = iCh;   % Indices of all selected channels (for all wavelengths)
maingui.axesSDG.iSrcDet = iSrcDet;  % Source-detector pairs



function pos = GetAxesSDGCurrentPoint(handles, eventdata)
if ~exist('eventdata','var')
    eventdata = [];
end
if isempty(eventdata)
    pos = get(handles.axesSDG, 'currentpoint');
elseif isa(eventdata, 'matlab.graphics.eventdata.Hit')
    pos = get(handles.axesSDG, 'currentpoint');
else    
    %     hCh = findChannel(handles.axesSDG);
    %     if isempty(hCh)
    %         return;
    %     end
    %     xdata = get(hCh, 'xdata');
    %     ydata = get(hCh, 'ydata');
    %     pos = [xdata(1) + ((xdata(2)-xdata(1))/2), ydata(1) + ((ydata(2)-ydata(1))/2)];
    pos = eventdata;
end



% ------------------------------------------------------------
% Find channel to click on artificially
function hCh = findChannel(haxes)
hCh = [];
hc = get(haxes, 'children');
for ii = 1:length(hc)
    if strcmpi(hc(ii).type, 'line')
        hCh = hc(ii);
        return;
    end
end
