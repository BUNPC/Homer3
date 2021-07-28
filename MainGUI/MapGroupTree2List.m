function iList = MapGroupTree2List(iGroup, iSubj, iRun)
global maingui

% Function to convert from processing element 3-tuple index to 
% a linear index used to select a listbox entry

viewSetting = maingui.listboxGroupTreeParams.viewSetting;
idxs = maingui.listboxGroupTreeParams.listMaps(viewSetting).idxs;

% Convert processing element tuple index to a scalar
scalar0 = index2scalar(iGroup, iSubj, iRun);

% Find closest match to processing element argument in the listMap 
for ii = 1:size(idxs, 1)
    ig = idxs(ii,1);
    is = idxs(ii,2);
    ir = idxs(ii,3);
    scalar1 = index2scalar(ig, is, ir);
    if scalar0<=scalar1
        break;
    end
end
iList = ii;



% -----------------------------------------------------
function scalar = index2scalar(ig, is, ir)
scalar = ig*100 + is*10 + ir;
