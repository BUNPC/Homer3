function stimGUI_DisplayData(userdata_curr_row)
global stim
aux = stim.currElem.procElem.aux;

if ~exist('userdata_curr_row')
    userdata_curr_row=0;
end

axes(stim.handles.axes)
cla
hold on 

if(~isempty(aux))
    h=plot(stim.currElem.procElem.t, aux(:,stim.iAux),'color','k');
end
[lstR,lstC] = find(abs(stim.currElem.procElem.s)==1);
[lstR,k] = sort(lstR);
lstC = lstC(k);
nStim = length(lstR);
yy = ylim();
stim.Lines=repmat(struct('handle',0,'color',[]),length(lstR),1);
idxLg=[];
hLg=[];
kk=1;
for ii=1:nStim
    if(stim.currElem.procElem.s(lstR(ii),lstC(ii))==1)
        stim.Lines(ii).handle = plot([1 1]*stim.currElem.procElem.t(lstR(ii)), yy,'-');
    elseif(stim.currElem.procElem.s(lstR(ii),lstC(ii))==-1)
        stim.Lines(ii).handle = plot([1 1]*stim.currElem.procElem.t(lstR(ii)), yy,'--');
    end

    iCond = stim.currElem.procElem.CondName2Group(lstC(ii));
    stim.Lines(ii).color = stim.CondColTbl(iCond,1:3);
    try 
        set(stim.Lines(ii).handle,'color',stim.Lines(ii).color);
    catch
        disp(sprintf('ERROR'));
    end
    if ii==userdata_curr_row
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthHighl);
    else
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthReg);
    end

    % Check which conditions are represented in S for the conditions 
    % legend display. 
    if isempty(find(idxLg == iCond))
        hLg(kk) = plot([1 1]*stim.currElem.procElem.t(1), yy,'-','color',stim.Lines(ii).color,'visible','off');
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end

if get(stim.handles.radiobuttonZoom,'value')==1    % Zoom
    h=zoom;
    set(h,'ButtonDownFilter',@myZoom_callback);
    set(h,'enable','on')
    set(stim.handles.axes,'Tag','axes')

    
elseif get(stim.handles.radiobuttonStim,'value')==1 % Stim
    zoom off
    set(stim.handles.axes,'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
    set(get(stim.handles.axes,'children'), 'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
end


if(~isproperty(stim,'userdata') | isempty(stim.userdata))
    data = repmat({0,''},length(lstR),1);
    for ii=1:length(lstR)
        data{ii,1} = stim.currElem.procElem.t(lstR(ii));
    end
    cnames={'1'};
    cwidth={100};
    ceditable=logical([1]);
elseif(isproperty(stim,'userdata') & isproperty(stim.userdata,'data') & isempty(stim.userdata.data))
    ncols = length(stim.userdata.cnames);
    data = [repmat({0},length(lstR),1) repmat({''},length(lstR),ncols)];
    for ii=1:length(lstR)
        data{ii,1} = stim.currElem.procElem.t(lstR(ii));
    end
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;
else
    data0     = stim.userdata.data;
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;

    ncols = size(data0,2);
    data  = cell(0,ncols);

    % Find which data to add/delete
    for ii=1:length(lstR)
        % Search for stim in current table
        data(ii,:) = [{0} repmat({''},1,ncols-1)];
        data{ii,1} = stim.currElem.procElem.t(lstR(ii));
        for jj=1:size(data0,1)
            tol=0.001; % ms tolerance
            if abs(data{ii,1}-data0{jj,1})<tol
                data(ii,:) = data0(jj,:);
            end
        end
    end
end
tableUserData_Update(stim.handles,data,cnames,cwidth,ceditable);

% Update legend
if(ishandle(stim.LegendHdl))
    delete(stim.LegendHdl);
    stim.LegendHdl = -1;
end
[idxLg,k] = sort(idxLg);
hLg = hLg(k);
if ~isempty(hLg)
    stim.LegendHdl = legend(hLg,stim.CondNamesGroup(idxLg));
end

set(stim.handles.axes,'xlim', [stim.currElem.procElem.t(1), stim.currElem.procElem.t(end)])



% ------------------------------------------------
function [flag] = myZoom_callback(obj,event_obj)

if strcmpi( get(obj,'Tag'), 'axes' )
    flag = 0;
else
    flag = 1;
end

