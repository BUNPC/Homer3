function iList = MapGroupTree2List(iGroup, iSubj, iRun)
global maingui

viewSetting = maingui.listboxGroupTreeParams.viewSetting;

iList = find(maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,1)==iGroup & ...
             maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,2)==iSubj & ...
             maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,3)==iRun);
         
if isempty(iList)
    iList=0;
end