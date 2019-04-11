function showHiddenObjs(iBlk, hData)
global plotprobe

if ~exist('hData','var')
    hData = plotprobe.handles.data;
end
y        = plotprobe.y{iBlk};
ch       = plotprobe.dataTree.currElem.GetMeasList(iBlk);
h        = hData;
bit0     = plotprobe.tMarkShow;
bit1     = plotprobe.hidMeasShow;

bitmask  = 2*bit1+bit0;

if isempty(y)
    return;
end
if ~ishandles(h)
    return;
end

nDataTypes = ndims(y);
MLact = ch.MeasListActAuto(ch.MeasList(:,4)==1); % option for future

j1 = find(MLact~=0);
j2 = find(MLact==0);
k1 = 1:nDataTypes;
k2 = nDataTypes+1:size(h,2);
switch bitmask
case 0
    set(h(j1,k1),'visible','on');
    set(h(j1,k2),'visible','off');
    set(h(j2,[k1 k2]),'visible','off');
case 1
    set(h(j1,[k1 k2]),'visible','on');
    set(h(j2,[k1 k2]),'visible','off');
case 2
    set(h([j1; j2],k1),'visible','on');
    set(h([j1; j2],k2),'visible','off');
case 3
    set(h([j1;j2],[k1 k2]),'visible','on');
end

