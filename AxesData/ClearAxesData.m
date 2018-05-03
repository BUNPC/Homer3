function ClearAxesData(axesData)


% clear axes
axes(axesData.handles.axes);
legend off
cla

ClearAxesSDG(axesData.axesSDG); 
