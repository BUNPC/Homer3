function plotprobe = InitPlotProbeFigure(plotprobe, guiMain, gui_enable)

if guiMain.flagPlotRange==true
    plotprobe.tMarkAmp = hmr.plotRange*1e-6;
else
    plotprobe.tMarkAmp = 0;
end

hFig = [];
if(gui_enable==1 & (isempty(plotprobe.objs.Figure.h) || ...
                    ~ishandle(plotprobe.objs.Figure.h)))

    hFig = figure;
    p = plotprobe.objs.Figure.pos;
    set(hFig, 'position', p);
    set(hFig,'DeleteFcn',@PlotProbe_DeleteFcn);
    xlim([0 1]);
    ylim([0 1]);
    plotprobe.objs.Figure.h = hFig;

elseif(gui_enable==0 & ishandle(plotprobe.objs.Figure.h))

    % Record latest plotProbe position and size in plotprobe
    % variable. This will be the next position/size parameters
    % next time plotProbe is activated.
    pos = get(plotprobe.objs.Figure.h,'position');
    plotprobe.objs.Figure.pos = pos;
    delete(plotprobe.objs.Figure.h);
    plotprobe.objs.Figure.h = [];
    return;

elseif gui_enable==1
    
    hFig = plotprobe.objs.Figure.h;
    
elseif gui_enable==0
    
    return;

end

