function [hf plotname] = CopyDisplayCurrElem(currElem, axesData)

hf = figure;
set(hf, 'color', [1 1 1]);
fields = fieldnames(axesData.guisetting);
plotname = sprintf('%s_%s', currElem.procElem.name, fields{axesData.datatype});
set(hf,'name', plotname);


% DISPLAY DATA
axesData.handles.axes = axes('position',[0.05 0.05 0.6 0.9]);

% DISPLAY SDG
axesData.axesSDG.handles.axes = axes('position',[0.65 0.05 0.3 0.9]);
axis off

DisplayCurrElem(currElem, axesData);

