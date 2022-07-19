function toggleLinesAxesSDG_ButtonDownFcn(hObject, eventdata, handles)

% This function is called when the user clicks on one of the meausrement
% lines in the SDG window

global maingui;

iSrcDet  = maingui.axesSDG.iSrcDet;
ch       = maingui.dataTree.currElem.GetMeasList();
chVis    = maingui.dataTree.currElem.GetMeasListVis();
Lambda   = maingui.dataTree.currElem.GetWls();

idx = eventdata;

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

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
    if all(chVis(lst))  % If the selected channel is visible
        chVis(lst) = 0;
    else
        chVis(lst) = 1;
    end
    % TODO implement a more elegant setter
    maingui.dataTree.currElem.SetMeasListVis(chVis);
    maingui.Update('PatchCallback');  % Refresh data display
    
%%%% Mouse left click: toggle manual exclude/deactivate channel
elseif strcmp(mouseevent, 'normal')
    if all(ch.MeasListActMan(lst))  % If the selected channel is active
        ch.MeasListActMan(lst) = 0;
    else
        ch.MeasListActMan(lst) = 1;
    end
    % TODO implement a more elegant setter
    maingui.dataTree.currElem.procStream.input.SetMeasListActMan(ch.MeasListActMan);
    
%%%% Exit function for any other mouse event 
else
    return;
end

DisplayAxesSDG(handles);

