function toggleLinesAxesSDG_ButtonDownFcn(hObject, ~, handles)
% This function is called when the user clicks directly on one of the measurement
% lines in the SDG axes
global maingui;

SD    = maingui.dataTree.currElem.GetSDG('2D');
ch    = maingui.dataTree.currElem.GetMeasList();

iWl_gui = GetWl(handles);

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

% Get the index of clicked channel
[iS, iD] = GetSelectedChannels(hObject, SD, ch);

%%%% Mouse right click: toggle channel visibility
if strcmp(mouseevent, 'alt')
    maingui.dataTree.currElem.SetMeasListVis([iS, iD]);
    maingui.Update('PatchCallback');  % Refresh data display
    
%%%% Mouse left click: toggle manual exclude/deactivate channel
elseif strcmp(mouseevent, 'normal')
    iChSelected = find(ch.MeasListActMan(:,1) == iS  &  ch.MeasListActMan(:,2) == iD);
    if ch.MeasListActMan(iChSelected,3)  % If the selected channel is active
        ch.MeasListActMan(iChSelected,3) = 0;
    else
        ch.MeasListActMan(iChSelected,3) = 1;
    end    
    maingui.dataTree.currElem.SetMeasListActMan(ch.MeasListActMan);
    
%%%% Exit function for any other mouse event 
else
    return;
end

DisplayAxesSDG(handles);




% -------------------------------------------------------------------------------
function [iS, iD] = GetSelectedChannels(hObject, SD, ch)
xdata = get(hObject,'xdata');
ydata = get(hObject,'ydata');
ml    = ch.MeasList;
SD_clicked_pos = [xdata(:), ydata(:), zeros(length(xdata),1)];

[~, iS] = nearest_point(SD.SrcPos, SD_clicked_pos(1,:));
[~, iD] = nearest_point(SD.DetPos, SD_clicked_pos(2,:));


