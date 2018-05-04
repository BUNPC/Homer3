function guiMain = SetAxesDataCh(guiMain, currElem)

% Find which channels were selected from axesSDG
guiMain.axesSDG = SetAxesSDGCh(guiMain.axesSDG, currElem);

guiMain.ch = GetAxesSDGSelection(guiMain.axesSDG);
