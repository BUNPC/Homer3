function [hf,plotname] = CopyDisplayCurrElem(currElem, guiMain)

hf = figure;
set(hf, 'color', [1 1 1]);
fields = fieldnames(guiMain.buttonVals);
plotname = sprintf('%s_%s', currElem.procElem.name, fields{guiMain.datatype});
set(hf,'name', plotname);


% DISPLAY DATA
guiMain.axesData.handles.axes = axes('position',[0.05 0.05 0.6 0.9]);

% DISPLAY SDG
guiMain.axesSDG.handles.axes = axes('position',[0.65 0.05 0.3 0.9]);
axis off

DisplayCurrElem(currElem, guiMain);

