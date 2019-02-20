function ClearAxesData(guiControls)


% clear axes
axes(guiControls.axesData.handles.axes);
legend off
cla

ClearAxesSDG(guiControls.axesSDG); 
