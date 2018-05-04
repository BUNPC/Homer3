function setWl(guiMain, Lambda)

for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
set(guiMain.handles.listboxPlotWavelength, 'string', strs);


