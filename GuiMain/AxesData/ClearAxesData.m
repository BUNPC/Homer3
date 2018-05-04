function ClearAxesData(guiMain)


% clear axes
axes(guiMain.axesData.handles.axes);
legend off
cla

ClearAxesSDG(guiMain.axesSDG); 
