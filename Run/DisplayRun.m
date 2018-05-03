function DisplayRun(run, axesData)

hAxes = axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end

axes(hAxes)
cla;
legend off

linecolor  = axesData.linecolor;
linestyle  = axesData.linestyle;
datatype   = axesData.datatype;
condition  = axesData.condition;
ch         = axesData.ch;
wl         = axesData.wl;
hbType     = axesData.hbType;
guisetting = axesData.guisetting;
sclConc    = axesData.sclConc;        % convert Conc from Molar to uMolar
showStdErr = axesData.showStdErr;

condition = find(run.CondRun2Group == condition);


d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == guisetting.RAW
    d = run.d;
    t = run.t;
elseif datatype == guisetting.OD
    d = run.procResult.dod;
    t = run.t;
elseif datatype == guisetting.CONC
    d = run.procResult.dc;
    t = run.t;
elseif datatype == guisetting.OD_HRF
    d = run.procResult.dodAvg;
    t = run.procResult.tHRF;
    if showStdErr 
        dStd = run.procResult.dodAvgStd;
    end
    nTrials = run.procResult.nTrials;
    if isempty(condition)
        return;
    end    
elseif datatype == guisetting.CONC_HRF
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
    if datatype == guisetting.RAW || ...
       datatype == guisetting.OD || ...
       datatype == guisetting.OD_HRF 

        if  datatype == guisetting.OD_HRF 
            d = d(:,:,condition);
        end
        d = reshape_y(d, SD);
        
        DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle);
        
    elseif datatype == guisetting.CONC || ...
           datatype == guisetting.CONC_HRF 

        if  datatype == guisetting.CONC_HRF 
            d = d(:,:,:,condition);
        end
        d = d * sclConc;

        DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle);
    end
end

axesData.axesSDG = DisplayAxesSDG(axesData.axesSDG, run);

% If HRF display is set then exit display without showing stims
if datatype == guisetting.CONC_HRF 
    return;
end
if datatype == guisetting.OD_HRF 
    return;
end
if datatype == guisetting.RAW_HRF
    return;
end

DisplayStim(run, axesData);
