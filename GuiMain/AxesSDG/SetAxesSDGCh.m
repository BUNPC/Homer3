function axesSDG = SetAxesSDGCh(axesSDG, currElem)


hAxesSDG = axesSDG.handles.axes;
iCh      = axesSDG.iCh;
iSrcDet  = axesSDG.iSrcDet;
SD       = currElem.procElem.SD;

if isempty(SD) 
    return;
end

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
for idx=1:SD.nSrcs
    ropt = ( (pos(1,1)-SD.SrcPos(idx,1))^2 + (pos(1,2)-SD.SrcPos(idx,2))^2 )^0.5 ;
    if ropt<rmin
        idxMin = idx;
        rmin = ropt;
    end
end
for idx=1:SD.nDets
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
    lst = find( SD.MeasList(:,1)==idxMin & SD.MeasList(:,4)==idxLambda );
else
    lst = find( SD.MeasList(:,2)==idxMin & SD.MeasList(:,4)==idxLambda );
end

% Remove any channels from lst which are already part of the hmr.plotLst
% to avoid confusion with double counting of channels
k = find(ismember(lst, axesSDG.iCh));
lst(k) = [];


if strcmp(mouseevent,'normal')   
    if SrcMin
        iCh = lst;
        iSrcDet = [idxMin*ones(length(lst),1) SD.MeasList(lst,2)];
    else
        iCh = lst;
        iSrcDet = [SD.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
elseif strcmp(mouseevent,'extend')
    if SrcMin
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [idxMin*ones(length(lst),1) SD.MeasList(lst,2)];
    else
        iCh(end+[1:length(lst)]) = lst;
        iSrcDet(end+[1:length(lst)],:) = [SD.MeasList(lst,1) idxMin*ones(length(lst),1)];
    end
end

axesSDG.iCh     = iCh;
axesSDG.iSrcDet = iSrcDet;

