function setWl(axesData, Lambda)

for ii=1:length(Lambda)
    strs{ii} = num2str(Lambda(ii));
end
set(axesData.handles.listboxPlotWavelength, 'string', strs);


