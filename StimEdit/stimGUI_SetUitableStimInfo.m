function stimGUI_SetUitableStimInfo(condition, handles)
global stimEdit

if ~exist('condition','var')
    return;
end
conditions =  stimEdit.dataTree.currElem.GetConditions();
if isempty(conditions)
    return;
end
icond = find(strcmp(conditions, condition));
if isempty(icond)
    return;
end
[tpts, duration, vals] = stimEdit.dataTree.currElem.GetStimData(icond);
if isempty(tpts)
    set(handles.uitableStimInfo, 'data',[]);
    return;
end
[~,idx] = sort(tpts);
data = zeros(length(tpts),3);
data(:,1) = tpts(idx);
data(:,2) = duration(idx);
data(:,3) = vals(idx);
set(handles.uitableStimInfo, 'data',data);


