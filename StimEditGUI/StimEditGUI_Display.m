function StimEditGUI_Display(handles)
global stimEdit

if isempty(stimEdit.dataTree)
    return;
end
if isempty(handles)
    return;
end
if ~ishandles(handles.axes1)
    return;
end

axes(handles.axes1)
cla(handles.axes1);
set(handles.axes1, 'ytick','');
hold(handles.axes1, 'on');

% As of now this operation is undefined for non-Run nodes (i.e., Subj and Group)
% So we clear the axes and exit
if stimEdit.dataTree.currElem.iRun==0
    return;
end

iG = stimEdit.dataTree.GetCurrElemIndexID();
CondNamesGroup = stimEdit.dataTree.group(iG).GetConditions();
CondColTbl     = stimEdit.dataTree.group(iG).CondColTbl();
t              = stimEdit.dataTree.currElem.GetTimeCombined();
s              = stimEdit.dataTree.currElem.GetStims(t);
stimVals       = stimEdit.dataTree.currElem.GetStimValSettings();

[lstR,lstC] = find(abs(s) ~= stimVals.none);
[lstR,k] = sort(lstR);
lstC = lstC(k);
nStim = length(lstR);
yy = get(handles.axes1, 'ylim');
Lines = InitStimLines(length(lstR));
idxLg=[];
hLg=[];
kk=1;
for ii=1:nStim
    if(s(lstR(ii),lstC(ii))==stimVals.incl)
        linestyle = '-';
    elseif(s(lstR(ii),lstC(ii))==stimVals.excl_manual)
        linestyle = '--';
    elseif(s(lstR(ii),lstC(ii))==stimVals.excl_auto)
        linestyle = '-.';
    end
    Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy, linestyle, 'parent',handles.axes1);
    
    iCond = lstC(ii);
    Lines(ii).color = CondColTbl(iCond,1:3);
    try
        set(Lines(ii).handle,'color',Lines(ii).color);
    catch
        fprintf('ERROR!!!!\n');
    end
    set(Lines(ii).handle, 'linewidth',Lines(ii).widthReg);
    
    % Check which conditions are represented in S for the conditions
    % legend display.
    if ~ismember(iCond, idxLg)
        hLg(kk) = plot([1 1]*t(1), yy,'-', 'color',Lines(ii).color, 'linewidth',4, 'visible','off', 'parent',handles.axes1);
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end

% Update legend
[idxLg,k] = sort(idxLg);
if ~isempty(hLg)
    hLg = legend(hLg(k), CondNamesGroup(idxLg));
end
set(handles.axes1,'xlim', [t(1), t(end)]);

% Update conditions popupmenu
set(handles.popupmenuConditions, 'string', sort(stimEdit.dataTree.currElem.GetConditions()));
conditions = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
condition = conditions{idx};
StimEditGUI_SetUitableStimInfo(condition, handles);


% -----------------------------------------------------------
function Lines = InitStimLines(n)
if ~exist('n','var')
    n = 0;
end
Lines = repmat( struct('handle',[], 'color',[], 'widthReg',2, 'widthHighl',4), n,1);


