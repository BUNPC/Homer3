function DisplayStim(run, guiMain)

hAxes = guiMain.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end
axes(hAxes);

buttonVals = guiMain.buttonVals;

if guiMain.datatype == buttonVals.RAW_HRF || guiMain.datatype == buttonVals.RAW_HRF_PLOT_PROBE
    return;
end
if guiMain.datatype == buttonVals.OD_HRF || guiMain.datatype == buttonVals.OD_HRF_PLOT_PROBE
    return;
end
if guiMain.datatype == buttonVals.CONC_HRF || guiMain.datatype == buttonVals.CONC_HRF_PLOT_PROBE
    return;
end

procResult = run.procResult;


%%% Plot stim marks. This has to be done before plotting exclude time 
%%% patches because stim legend doesn't work otherwise.
if ~isempty(run.s)
    run.s = enStimRejection(run.t, run.s, [], run.tIncMan, [0 0]);
    s = run.s;
    
    % Plot included and excluded stims
    yrange=ylim();
    hLg=[]; 
    idxLg=[];
    kk=1;
    CondColTbl = GetCondColTbl();
    for iS = 1:size(s,2)
        iCond = run.CondRun2Group(iS);

        lstS          = find(run.s(:,iS)==1 | run.s(:,iS)==-1);
        lstExclS_Auto = [];
        lstExclS_Man  = find(s(:,iS)==-1);
        if isproperty(procResult,'s') && ~isempty(procResult.s)
            lstExclS_Auto = find(s(:,iS)==1 & sum(procResult.s,2)<=-1);
        end
         
        for iS2=1:length(lstS)
            if ~isempty(find(lstS(iS2) == lstExclS_Auto))
                hl = plot(run.t(lstS(iS2))*[1 1],yrange,'-.');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            elseif ~isempty(find(lstS(iS2) == lstExclS_Man))
                hl = plot(run.t(lstS(iS2))*[1 1],yrange,'--');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            else
                hl = plot(run.t(lstS(iS2))*[1 1],yrange,'-');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            end
        end
        
        % Get handles and indices of each stim condition 
        % for legend display
        if ~isempty(lstS)
            % We don't want dashed lines appearing in legend, so 
            % we draw invisible solid stims over all stims to 
            % trick the legend into only showing solid lines.
            hLg(kk) = plot(run.t(lstS(iS2))*[1 1],yrange,'-','visible','off');
            set(hLg(kk),'color',CondColTbl(iCond,:));
            idxLg(kk) = iCond;
            kk=kk+1;
        end
        DisplayCondLegend(hLg, idxLg);
    end    
end
hold off
