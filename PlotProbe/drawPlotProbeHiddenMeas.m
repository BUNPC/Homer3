function obj = drawPlotProbeHiddenMeas(obj,hParent,hidMeasShow, hFig)

if ishandles(obj.h)
    return;
end
if ~ishandles(hFig)
    return;
end

figure(hFig);
color_fig = get(hFig,'color');
obj.h = uicontrol('parent',hParent,'style','radiobutton','Tag','radiobuttonPlotProbeShowHiddenMeas',...
                  'units','normalized','position',obj.pos,...
                  'value', hidMeasShow, ...
                  'string','show Hidden Measurements','backgroundcolor',color_fig,...
                  'callback',@radiobuttonShowHiddenMeas_Callback);
