function toggleLinesAxesSDG_ButtonDownFcn(hObject, ~, handles)
% This function is called when the user clicks directly on one of the measurement
% lines in the SDG axes
global maingui;

SD    = maingui.dataTree.currElem.GetSDG('2D');
ch    = maingui.dataTree.currElem.GetMeasList();
ml    = ch.MeasList;

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

% Get the index of clicked channel
iChSelected = GetSelctedChannels(hObject, SD, ch);

%%%% Mouse right click: toggle channel visibility
if strcmp(mouseevent, 'alt')
    % TODO implement a more elegant setter
    maingui.dataTree.currElem.SetMeasListVis(ml(iChSelected(1),1:2));
    maingui.Update('PatchCallback');  % Refresh data display
    
%%%% Mouse left click: toggle manual exclude/deactivate channel
elseif strcmp(mouseevent, 'normal')
    if all(ch.MeasListActMan(iChSelected))  % If the selected channel is active
        ch.MeasListActMan(iChSelected) = 0;
    else
        ch.MeasListActMan(iChSelected) = 1;
    end
    
    % TODO implement a more elegant setter
    maingui.dataTree.currElem.procStream.input.SetMeasListActMan(ch.MeasListActMan);
    
%%%% Exit function for any other mouse event 
else
    return;
end

DisplayAxesSDG(handles);




% -------------------------------------------------------------------------------
function iChSelected = GetSelctedChannels(hObject, SD, ch)
xdata = get(hObject,'xdata');
ydata = get(hObject,'ydata');
ml    = ch.MeasList;
SD_clicked_pos = [xdata(:), ydata(:), zeros(length(xdata),1)];

[~, iS] = nearest_point(SD.SrcPos, SD_clicked_pos(1,:));
[~, iD] = nearest_point(SD.DetPos, SD_clicked_pos(2,:));

iChSelected = find(ml(:,1) == iS  &  ml(:,2) == iD);

