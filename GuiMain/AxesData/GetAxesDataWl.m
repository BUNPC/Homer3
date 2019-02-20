function GetAxesDataWl()
global hmr
Lambda =  hmr.dataTree.currElem.procElem.GetWls();

hmr.guiControls.wl = getWl(hmr.guiControls, Lambda);