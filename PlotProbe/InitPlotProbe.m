function plotprobe = InitPlotProbe(handles)

plotprobe = [];

plotprobe.axScl = [1,1];
plotprobe.plotname = [];
plotprobe.tMarkInt = 5;
plotprobe.tMarkAmp = 0;
plotprobe.tMarkShow = 0;
plotprobe.hidMeasShow = 0;
plotprobe.plotCondition_run = 1;
plotprobe.plotCondition = 1;

if exist('handles','var')
    plotprobe.active = get(handles.checkboxPlotProbe, 'value');
else
    plotprobe.active = 0;
end


plotprobe.objs.Data.h = [];
plotprobe.objs.Data.pos = [];

plotprobe.objs.CtrlPanel.h = [];
plotprobe.objs.CtrlPanel.pos    = [0.00, 0.00, 1.00, 0.22];

plotprobe.objs.TmarkPanel.h = [];
plotprobe.objs.TmarkPanel.pos   = [0.20, 0.00, 0.30, 1.00];

plotprobe.objs.SclPanel.h = [];
plotprobe.objs.SclPanel.pos     = [0.00, 0.00, 0.20, 1.00];

plotprobe.objs.BttnDup.h = [];
plotprobe.objs.BttnDup.pos      = [0.52, 0.54, 0.15, 0.25];

plotprobe.objs.BttnHidMeas.h = [];
plotprobe.objs.BttnHidMeas.pos  = [0.52, 0.14, 0.30, 0.25];

scrsz = get(0,'ScreenSize');
rdfx = 2.2;
rdfy = rdfx-.5;
plotprobe.objs.Figure.h = [];
plotprobe.objs.Figure.pos = [1, scrsz(4)/2-scrsz(4)*.2, scrsz(3)/rdfx, scrsz(4)/rdfy];


