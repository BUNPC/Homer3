function toggleLinesAxesSDG_ButtonDownFcn(hObject, ~, handles)

% This function is called when the user clicks on one of the meausrement
% lines in the SDG window

global maingui;

ch       = maingui.dataTree.currElem.GetMeasList();
SD       = maingui.dataTree.currElem.GetSDG('2D');

mouseevent = get(get(get(hObject,'parent'),'parent'),'selectiontype');

% Get the index of clicked channel
lst = [];
xdata = get(hObject,'xdata');
ydata = get(hObject,'ydata');
SD_clicked_pos = [xdata(:), ydata(:), zeros(length(xdata),1)];
ml = ch.MeasList;
errmgn = .5;
for ii = 1:size(ml,1)
    if      (dist3(SD.SrcPos(ml(ii,1),:), SD_clicked_pos(1,:)) < errmgn)  &&  (dist3(SD.DetPos(ml(ii,2),:), SD_clicked_pos(2,:)) < errmgn)
        lst = [lst; ii];
    elseif  (dist3(SD.DetPos(ml(ii,2),:), SD_clicked_pos(1,:)) < errmgn)  &&  (dist3(SD.SrcPos(ml(ii,1),:), SD_clicked_pos(2,:)) < errmgn)
        lst = [lst; ii];
    end
end

%%%% Mouse right click: toggle channel visibility
if strcmp(mouseevent, 'alt')    
    % TODO implement a more elegant setter
    maingui.dataTree.currElem.SetMeasListVis(ml(lst(1),1:2));
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

