function PlotProbe_DeleteFcn(hObject,eventdata,handles)
global plotprobe
global hmr

plotprobe.objs.Data.h = [];

plotprobe.objs.Figure.h = [];

plotprobe.objs.CtrlPanel.h = [];

plotprobe.objs.BttnDup.h = [];

plotprobe.objs.BttnHidMeas.h = [];

plotprobe.objs.SclPanel.h = [];

plotprobe.objs.TmarkPanel.h = [];

