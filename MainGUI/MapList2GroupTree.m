function [iGroup, iSubj, iRun] = MapList2GroupTree(iList)
global hmr

viewSetting = hmr.listboxGroupTreeParams.viewSetting;

iGroup = hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,1);
iSubj  = hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,2);
iRun   = hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,3);
