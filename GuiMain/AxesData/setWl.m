function setWl(guiControls, Lambda)

for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
set(guiControls.handles.listboxPlotWavelength, 'string', strs);


