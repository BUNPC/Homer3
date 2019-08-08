function ch = GetAxesSDGSelection()
global hmr
guiControls = hmr.guiControls;
guiControls.ch = guiControls.axesSDG.iCh;
hmr.guiControls = guiControls;
