function DisplaySubj(subj, guiMain)

hAxes = guiMain.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end

axes(hAxes)
cla;
legend off

linecolor  = guiMain.axesData.linecolor;
linestyle  = guiMain.axesData.linestyle;
datatype   = guiMain.datatype;
condition  = guiMain.condition;
ch         = guiMain.ch;
wl         = guiMain.wl;
hbType     = guiMain.hbType;
buttonVals = guiMain.buttonVals;
sclConc    = guiMain.sclConc;        % convert Conc from Molar to uMolar
showStdErr = guiMain.showStdErr;

condition = find(subj.CondSubj2Group == condition);

d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == buttonVals.OD_HRF || datatype == buttonVals.OD_HRF_PLOT_PROBE
    t = subj.procResult.tHRF;
    d = subj.procResult.dodAvg;
    if showStdErr 
        dStd = subj.procResult.dodAvgStd;
    end
    nTrials = subj.procResult.nTrials;
elseif datatype == buttonVals.CONC_HRF || datatype == buttonVals.CONC_HRF_PLOT_PROBE
    t = subj.procResult.tHRF;
    d = subj.procResult.dcAvg;
    if showStdErr 
        dStd = subj.procResult.dcAvgStd * sclConc;
    end
    nTrials = subj.procResult.nTrials;
end
SD = subj.SD;

if isempty(condition)
    return;
end

%%% Plot data 
if ~isempty(d)

    xx = xlim();
    yy = ylim();
    if strcmpi(get(hAxes,'ylimmode'),'manual')
        flagReset = 0;
    else
        flagReset = 1;
    end
    hold on
    
    % Set the axes ranges  
    if flagReset==1
        set(hAxes,'xlim',[floor(min(t)) ceil(max(t))]);
        set(hAxes,'ylimmode','auto');
    else
        xlim(xx);
        ylim(yy);
    end

    chLst = find(SD.MeasListVis(ch)==1);
   
    % Plot data
    if datatype == buttonVals.OD_HRF || datatype == buttonVals.OD_HRF_PLOT_PROBE

        d = d(:,:,condition);
        d = reshape_y(d, SD);
                
        DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle);

    elseif datatype == buttonVals.CONC_HRF || datatype == buttonVals.CONC_HRF_PLOT_PROBE
        
        d = d(:,:,:,condition) * sclConc;

        DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle);
        
    end

end        

guiMain.axesSDG = DisplayAxesSDG(guiMain.axesSDG, subj);
