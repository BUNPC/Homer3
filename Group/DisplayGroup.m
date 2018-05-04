function DisplayGroup(group, guiMain)

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

d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == buttonVals.OD_HRF
    t = group.procResult.tHRF;
    d = group.procResult.dodAvg;
    if showStdErr 
        dStd = group.procResult.dodAvgStd;
    end
    nTrials = group.procResult.nTrials;
elseif datatype == buttonVals.CONC_HRF
    t = group.procResult.tHRF;
    d = group.procResult.dcAvg;
    if showStdErr 
        dStd = group.procResult.dcAvgStd * sclConc;
    end
    nTrials = group.procResult.nTrials;
end
SD = group.SD;

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
    if datatype == buttonVals.OD_HRF 

        d = d(:,:,condition);
        d = reshape_y(d, SD);
                
        DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle);

    elseif datatype == buttonVals.CONC_HRF 

        d = d(:,:,:,condition) * sclConc;

        DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle);

    end
end        

guiMain.axesSDG = DisplayAxesSDG(guiMain.axesSDG, group);
