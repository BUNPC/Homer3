function obj = drawPlotProbeDuplicate(obj,hParent,hFig)

if ishandles(obj.h)
    return;
end
if ~ishandles(hFig)
    return;
end

obj.h(1) = uicontrol('parent',hParent,'style','pushbutton','tag','pushbuttonPlotProbeDuplicate',...
                     'units','normalized','position',obj.pos,...
                     'string','Duplicate Plot',...
                     'callback',@pushbuttonPlotProbeDuplicate_Callback);
