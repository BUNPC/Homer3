function iSD = GetSelectedSDPairIndex(iS, iD)
global maingui

SD       = maingui.dataTree.currElem.GetSDG();
iSrcDet  = maingui.axesSDG.iSrcDet;
nSDPairsSelected = size(iSrcDet,1);

nSrcs = length(SD.SrcPos);

iSDs = mod(iSrcDet(:,1) .* nSrcs + iSrcDet(:,2), nSDPairsSelected) + 1;
for ii = 1:length(iSDs)
    iSD = mod(iSrcDet(ii,1) * nSrcs + iSrcDet(ii,2), nSDPairsSelected) + 1;
    k = find(iSDs == iSD);
    for kk = 1:length(k)-1
        if k(kk) == ii
            continue
        end
        nextslot = FindNextSlot(iSDs);
        if sum(iSrcDet(k(kk),:)) > sum(iSrcDet(ii,:))
            iSDs(k(kk)) = nextslot;
        elseif sum(iSrcDet(kk,:)) == sum(iSrcDet(ii,:))
            if iSrcDet(k(kk),1) > iSrcDet(ii,1)
                iSDs(k(kk)) = nextslot;
            else
                iSDs(ii) = nextslot;
            end
        else
            iSDs(ii) = nextslot;
        end
        if length(find(iSDs == iSD))<2
            break;
        end
    end
end

idx = find(iSrcDet(:,1)==iS & iSrcDet(:,2)==iD);
iSD = iSDs(idx);




% --------------------------------------------------------------------------
function [nextslot, slots] = FindNextSlot(a)
slots = [];
if ~exist('a','var')
    a = [];
end
a = sort(a);
if isempty(a)
    a2 = 1;
else
    a2 = 1:a(end)+1;
end

kk = 1;
for ii = 1:length(a2)
    if ~ismember(a2(ii), a)
        slots(kk) = a2(ii);
        kk = kk+1;
    end
end
if isempty(slots)
    slots(1) = a(end)+1;
end
nextslot = slots(1);



