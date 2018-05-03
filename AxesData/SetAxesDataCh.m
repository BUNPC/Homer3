function axesData = SetAxesDataCh(axesData, currElem)

% Find which channels were selected from axesSDG
axesData.axesSDG = SetAxesSDGCh(axesData.axesSDG, currElem);

axesData.ch = GetAxesSDGSelection(axesData.axesSDG);
