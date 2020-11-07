function toggleLinesAxesSDG_ButtonDownFcn(hObject, eventdata, handles)

% This function is called when the user clicks on one of the meausrement
% lines in the SDG window

global maingui;

hAxesSDG = maingui.axesSDG.handles.axes;
iSrcDet  = maingui.axesSDG.iSrcDet;

SD       = maingui.dataTree.currElem(1).GetSDG();
ch       = maingui.dataTree.currElem(1).GetMeasList();
Lambda   = maingui.dataTree.currElem(1).GetWls();

idx = eventdata;

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

% Change measListAct
h2 = get(hAxesSDG, 'children');  %The list of all the lines currently displayed

% Get the index of clicked channel
lst = [];
for ii=1:length(Lambda)
    lst1 = find(ch.MeasList(:, 4) == ii);
    lst2 = find(ch.MeasList(lst1, 1) == iSrcDet(idx, 1) & ...
                ch.MeasList(lst1, 2) == iSrcDet(idx, 2) );
            
    lst = [lst, length(lst1) * (ii - 1) + lst2];
    
end

%%%% Mouse right click: toggle channel visibility
if strcmp(mouseevent, 'alt')
    if all(ch.MeasListVis(lst))  % If the selected channel is visible
        ch.MeasListVis(lst) = 0;
    else
        ch.MeasListVis(lst) = 1;
    end
    % TODO implement a more elegant setter
    maingui.dataTree.currElem(1).procStream.input.SetMeasListVis(ch.MeasListVis);
    maingui.Update('PatchCallback');  % Refresh data display
    
%%%% Mouse left click: toggle manual exclude/deactivate channel
elseif strcmp(mouseevent, 'normal')
    if all(ch.MeasListActMan(lst))  % If the selected channel is active
        ch.MeasListActMan(lst) = 0;
    else
        ch.MeasListActMan(lst) = 1;
    end
    % TODO implement a more elegant setter
    maingui.dataTree.currElem(1).procStream.input.SetMeasListActMan(ch.MeasListActMan);
    
%%%% Exit function for any other mouse event 
else
    return;
end

DisplayAxesSDG();

