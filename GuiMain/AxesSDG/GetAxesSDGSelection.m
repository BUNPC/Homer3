function ch = GetAxesSDGSelection()
global hmr
guiMain = hmr.guiMain;
guiMain.ch = guiMain.axesSDG.iCh;
hmr.guiMain = guiMain;
