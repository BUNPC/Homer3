function GetAxesDataWl()
global hmr
Lambda =  hmr.dataTree.currElem.procElem.GetWls();

hmr.guiMain.wl = getWl(hmr.guiMain, Lambda);