function [iGroup, iSubj, iRun] = MapList2GroupTree(iList)
global maingui

viewSetting = maingui.listboxGroupTreeParams.viewSetting;

iGroup = maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,1);
iSubj  = maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,2);
iRun   = maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,3);
