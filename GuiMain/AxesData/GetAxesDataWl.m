function GetAxesDataWl()
global hmr
Lambda =  hmr.dataTree.currElem.GetWls();

hmr.guiControls.wl = getWl(hmr.guiControls, Lambda);