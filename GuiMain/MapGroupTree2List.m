function iList = MapGroupTree2List(iGroup, iSubj, iRun)
global hmr

viewSetting = hmr.listboxGroupTreeParams.viewSetting;

iList = find(hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,1)==iGroup & ...
             hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,2)==iSubj & ...
             hmr.listboxGroupTreeParams.listMaps(viewSetting).idxs(:,3)==iRun);
         
if isempty(iList)
    iList=0;
end