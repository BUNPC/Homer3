function stimGUI_DisplayData()
global stimGui

dataTree = stimGui.dataTree; 

aux        = dataTree.currElem.procElem.GetAuxiliary();
t          = dataTree.currElem.procElem.GetTime();
s          = dataTree.currElem.procElem.GetStims();
CondColTbl = dataTree.group.GetCondColTbl();

axes(stimGui.handles.axes1)
cla
hold on 

if(~isempty(aux))
    h=plot(t, aux.data(:,stimGui.iAux),'color','k');
end
[lstR,lstC] = find(abs(s)==1);
[lstR,k] = sort(lstR);
lstC = lstC(k);
nStim = length(lstR);
yy = ylim();
stimGui.InitStimLines(length(lstR));
idxLg=[];
hLg=[];
kk=1;
for ii=1:nStim
    if(s(lstR(ii),lstC(ii))==1)
        stimGui.Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy,'-');
    elseif(stimGui.currElem.procElem.s(lstR(ii),lstC(ii))==-1)
        stimGui.Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy,'--');
    end

    iCond = stimGui.currElem.procElem.CondName2Group(lstC(ii));
    stimGui.Lines(ii).color = CondColTbl(iCond,1:3);
    try 
        set(stimGui.Lines(ii).handle,'color',stimGui.Lines(ii).color);
    catch
        disp(sprintf('ERROR'));
    end
    if ii==userdata_curr_row
        set(stimGui.Lines(ii).handle,'linewidth',stimGui.Lines(ii).widthHighl);
    else
        set(stimGui.Lines(ii).handle,'linewidth',stimGui.Lines(ii).widthReg);
    end

    % Check which conditions are represented in S for the conditions 
    % legend display. 
    if isempty(find(idxLg == iCond))
        hLg(kk) = plot([1 1]*t(1), yy,'-','color',stimGui.Lines(ii).color,'visible','off');
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end

if get(stimGui.handles.radiobuttonZoom,'value')==1    % Zoom
    h=zoom;
    set(h,'ButtonDownFilter',@myZoom_callback);
    set(h,'enable','on')
    set(stimGui.handles.axes,'Tag','axes')

    
elseif get(stimGui.handles.radiobuttonStim,'value')==1 % Stim
    zoom off
    set(stimGui.handles.axes,'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
    set(get(stimGui.handles.axes,'children'), 'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
end

% Update legend
if(ishandle(stimGui.LegendHdl))
    delete(stimGui.LegendHdl);
    stimGui.LegendHdl = -1;
end
[idxLg,k] = sort(idxLg);
hLg = hLg(k);
if ~isempty(hLg)
    stimGui.LegendHdl = legend(hLg,stimGui.CondNamesGroup(idxLg));
end

set(stimGui.handles.axes,'xlim', [t(1), t(end)])



% ------------------------------------------------
function [flag] = myZoom_callback(obj,event_obj)

if strcmpi( get(obj,'Tag'), 'axes' )
    flag = 0;
else
    flag = 1;
end

