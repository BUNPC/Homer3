function setWl(guiControls, Lambda)
if isempty(Lambda)
    return;
end
for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
set(guiControls.handles.listboxPlotWavelength, 'string', strs);


