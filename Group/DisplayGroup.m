function DisplayGroup(group, axesData)

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

d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == guisetting.OD_HRF
    t = group.procResult.tHRF;
    d = group.procResult.dodAvg;
    if showStdErr 
        dStd = group.procResult.dodAvgStd;
    end
    nTrials = group.procResult.nTrials;
elseif datatype == guisetting.CONC_HRF
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
    if datatype == guisetting.OD_HRF 

        d = d(:,:,condition);
        d = reshape_y(d, SD);
                
        DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle);

    elseif datatype == guisetting.CONC_HRF 

        d = d(:,:,:,condition) * sclConc;

        DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle);

    end
end        

axesData.axesSDG = DisplayAxesSDG(axesData.axesSDG, group);
