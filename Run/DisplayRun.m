function DisplayRun(run, guiMain)

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

condition = find(run.CondRun2Group == condition);


d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == buttonVals.RAW
    d = run.d;
    t = run.t;
elseif datatype == buttonVals.OD
    d = run.procResult.dod;
    t = run.t;
elseif datatype == buttonVals.CONC
    d = run.procResult.dc;
    t = run.t;
elseif datatype == buttonVals.OD_HRF
    d = run.procResult.dodAvg;
    t = run.procResult.tHRF;
    if showStdErr 
        dStd = run.procResult.dodAvgStd;
    end
    nTrials = run.procResult.nTrials;
    if isempty(condition)
        return;
    end    
elseif datatype == buttonVals.CONC_HRF
    d = run.procResult.dcAvg;
    t = run.procResult.tHRF;
    if showStdErr 
        dStd = run.procResult.dcAvgStd * sclConc;
    end
    nTrials = run.procResult.nTrials;
    if isempty(condition)
        return;
    end
end
SD = run.SD;


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
    if datatype == buttonVals.RAW || ...
       datatype == buttonVals.OD || ...
       datatype == buttonVals.OD_HRF 

        if  datatype == buttonVals.OD_HRF 
            d = d(:,:,condition);
        end
        d = reshape_y(d, SD);
        
        DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle);
        
    elseif datatype == buttonVals.CONC || ...
           datatype == buttonVals.CONC_HRF 

        if  datatype == buttonVals.CONC_HRF 
            d = d(:,:,:,condition);
        end
        d = d * sclConc;

        DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle);
    end
end

guiMain.axesSDG = DisplayAxesSDG(guiMain.axesSDG, run);

% If HRF display is set then exit display without showing stims
if datatype == buttonVals.CONC_HRF 
    return;
end
if datatype == buttonVals.OD_HRF 
    return;
end
if datatype == buttonVals.RAW_HRF
    return;
end

DisplayStim(run, guiMain);
