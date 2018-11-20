function toggleLinesAxesSDG_ButtonDownFcn(hObject, eventdata, handles)

% This function is called when the user clicks on one of the meausrement
% lines in the SDG window

global hmr;

currElem = hmr.currElem;
guiMain = hmr.guiMain;
group    = hmr.group;

axesSDG  = guiMain.axesSDG;

hAxesSDG = axesSDG.handles.axes;
iSrcDet  = axesSDG.iSrcDet;

SD       = currElem.procElem.GetSDG();
ch       = currElem.procElem.GetMeasList();
Lambda   = currElem.procElem.GetWls();

idx = eventdata;

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

% Change measListAct
h2=get(hAxesSDG,'children');  %The list of all the lines currently displayed

lst = [];
for ii=1:length(Lambda)
    lst1 = find(ch.MeasList(:,4)==ii);
    lst2  = find(ch.MeasList(lst1,1)==iSrcDet(idx,1) &...
                 ch.MeasList(lst1,2)==iSrcDet(idx,2) );
    lst = [lst, length(lst1)*(ii-1)+lst2];
end

%%%% If mouse right click, make channel data invisible
% Switch the linestyles based on a combination 
% of prune channel and visibility status
if strcmp(mouseevent,'alt')
    if strcmp(get(h2(idx),'linestyle'), '-')
        set(h2(idx),'linestyle',':')
        ch.MeasListVis(lst)=0;
    elseif strcmp(get(h2(idx),'linestyle'), '--')
        set(h2(idx),'linestyle','-.')
        ch.MeasListVis(lst)=0;
    elseif strcmp(get(h2(idx),'linestyle'), ':')
        set(h2(idx),'linestyle','-')
        ch.MeasListVis(lst)=1;
    elseif strcmp(get(h2(idx),'linestyle'), '-.')
        set(h2(idx),'linestyle','--')
        ch.MeasListVis(lst)=1;
    end
    
%%%% If mouse nromal left click, prune channel data 
elseif strcmp(mouseevent,'normal')
    if strcmp(get(h2(idx),'linestyle'), '-')
        set(h2(idx),'linestyle','--')
        ch.MeasListAct(lst)=0;
    elseif strcmp(get(h2(idx),'linestyle'), '--')
        set(h2(idx),'linestyle','-.')
        ch.MeasListAct(lst)=1;
    elseif strcmp(get(h2(idx),'linestyle'), ':')
        set(h2(idx),'linestyle','-')
        ch.MeasListAct(lst)=0;
    elseif strcmp(get(h2(idx),'linestyle'), '-.')
        set(h2(idx),'linestyle','--')
        ch.MeasListAct(lst)=1;
    end
    
%%%% Exit function for any other mouse event 
else
    return;
end

% Next 3 lines need to be replaces by a class method
% currElem.procElem.ToggleChannel(SD);
currElem.procElem.SD = SD;
% group = SaveCurrElem(currElem, hmr.group, 'temp', 'SD');
% group = UpdateGroupSD(group);

DisplayAxesSDG(axesSDG, currElem.procElem);
DisplayCurrElem(currElem, guiMain);

hmr.currElem = currElem;
hmr.group    = group;


