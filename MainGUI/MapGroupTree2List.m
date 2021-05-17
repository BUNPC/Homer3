function iList = MapGroupTree2List(iGroup, iSubj, iRun)
global maingui

% Function to convert from processing element 3-tuple index to 
% a linear index used to select a listbox entry

viewSetting = maingui.listboxGroupTreeParams.viewSetting;
idxs = maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs;

% Convert processing element tuple index to a scalar
base = size(idxs,2);
scalar0 = iGroup*base^2 + iSubj*base + iRun;

% Find closest match to processing element argument in the listMap 
for ii = 1:size(idxs, 1)
    ig = idxs(ii,1);
    is = idxs(ii,2);
    ir = idxs(ii,3);
    scalar1 = ig*base^2 + is*base + ir;
    if scalar0<=scalar1
        iList = ii;
        return;
    end
end
iList = ii;

