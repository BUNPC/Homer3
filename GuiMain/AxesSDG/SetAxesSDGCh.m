function SetAxesSDGCh()
global hmr
axesSDG = hmr.guiMain.axesSDG;
currElem = hmr.dataTree.currElem;

hAxesSDG = axesSDG.handles.axes;
iCh      = axesSDG.iCh;
iSrcDet  = axesSDG.iSrcDet;
SD       = currElem.procElem.GetSDG();
ch       = currElem.procElem.GetMeasList();

% Maximum number of channels that can be selected simultaneously
maxCh    = size(axesSDG.linecolor,1);

h = hAxesSDG;
while ~strcmpi(get(h,'type'),'figure')
    h = get(h,'parent');
end
mouseevent = get(h,'selectiontype');

pos = get(hAxesSDG, 'currentpoint');

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

% Copied from cw6_plotLst
idxLambda = 1;  %hmr.displayLambda;
if SrcMin
    lst = find( ch.MeasList(:,1)==idxMin & ch.MeasList(:,4)==idxLambda );
else
    lst = find( ch.MeasList(:,2)==idxMin & ch.MeasList(:,4)==idxLambda );
end

% Remove any channels from lst which are already part of the axesSDG.iCh
% to avoid confusion with double counting of channels
lst(ismember(lst, axesSDG.iCh)) = [];

if strcmp(mouseevent,'normal')
    if SrcMin
        iCh = lst;
        iSrcDet = [idxMin*ones(length(lst),1) ch.MeasList(lst,2)];
    else
        iCh = lst;
        iSrcDet = [ch.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
elseif strcmp(mouseevent,'extend')
    if SrcMin
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [idxMin*ones(length(lst),1) ch.MeasList(lst,2)];
    else
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [ch.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
end

if length(iCh) > maxCh
    menu('Number of selected channels exceeds max for waterfall display.','OK');
    return;
end
axesSDG.iCh     = iCh;
axesSDG.iSrcDet = iSrcDet;

hmr.guiMain.axesSDG = axesSDG;
