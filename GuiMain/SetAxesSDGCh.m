function SetAxesSDGCh(handles)
global hmr

hAxesSDG = hmr.axesSDG.handles.axes;
iCh      = hmr.axesSDG.iCh;
iSrcDet  = hmr.axesSDG.iSrcDet;
SD       = hmr.dataTree.currElem.GetSDG();

nDataBlks = hmr.dataTree.currElem.GetDataBlocksNum();
ml = [];
for iBlk = 1:nDataBlks
    ch = hmr.dataTree.currElem.GetMeasList(iBlk);
    ml = [ml; ch.MeasList];
end

% Maximum number of channels that can be selected simultaneously
maxCh    = size(hmr.axesSDG.linecolor,1);

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
    lst = find( ml(:,1)==idxMin & ml(:,4)==idxLambda );
else
    lst = find( ml(:,2)==idxMin & ml(:,4)==idxLambda );
end

% Remove any channels from lst which are already part of the axesSDG.iCh
% to avoid confusion with double counting of channels
% lst(ismember(lst, axesSDG.iCh)) = [];
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

if length(iCh) > maxCh
    menu('Number of selected channels exceeds max for waterfall display.','OK');
    return;
end

hmr.axesSDG.iCh     = iCh;
hmr.axesSDG.iSrcDet = iSrcDet;

