function plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain)

if ~plotprobe.active
    if ishandles(plotprobe.objs.Figure.h)
        delete(plotprobe.objs.Figure.h);
    end
    plotprobe.objs.Figure.h = [];
    return;    
end

axScl       = plotprobe.axScl;
tMarkInt    = plotprobe.tMarkInt;
tMarkAmp    = plotprobe.tMarkAmp;
tMarkShow   = plotprobe.tMarkShow;
hidMeasShow = plotprobe.hidMeasShow;

CtrlPanel   = plotprobe.objs.CtrlPanel;
SclPanel    = plotprobe.objs.SclPanel;
BttnDup     = plotprobe.objs.BttnDup;
BttnHidMeas = plotprobe.objs.BttnHidMeas;
TmarkPanel  = plotprobe.objs.TmarkPanel;
hFig        = plotprobe.objs.Figure.h;

procResult  = currElem.procElem.procResult;
SD          = currElem.procElem.GetSD();
ch          = currElem.procElem.GetMeasList();

datatype    = guiMain.datatype;
hbType      = guiMain.hbType;
buttonVals  = guiMain.buttonVals;
sclConc     = guiMain.sclConc;        % convert Conc from Molar to uMolar
showStdErr  = guiMain.showStdErr;


if currElem.procType==1
    condition  = guiMain.condition;
elseif currElem.procType==2
    condition = find(currElem.procElem.CondName2Group == guiMain.condition);
elseif currElem.procType==3
    condition  = find(currElem.procElem.CondName2Group == guiMain.condition);
end

y = [];
if datatype == buttonVals.OD_HRF_PLOT_PROBE
    y = procResult.dodAvg(:, :, condition);
    tMarkUnits='(AU)';
elseif datatype == buttonVals.CONC_HRF_PLOT_PROBE
    y = procResult.dcAvg(:, :, :, condition);
    tMarkAmp = tMarkAmp*1e6;
    tMarkUnits='(micro-molars)';
else
    return;
end
tHRF = procResult.tHRF;

[hData, hFig, tMarkAmp] = plotProbe( y, tHRF, SD, ch, hFig, [], axScl, tMarkInt, tMarkAmp );

% Modify and add graphics objects in plot probe figure
CtrlPanel    = drawPlotProbeControlsPanel( CtrlPanel, hFig );
SclPanel     = drawPlotProbeScale( SclPanel, CtrlPanel.h, axScl, hFig );
BttnDup      = drawPlotProbeDuplicate( BttnDup, CtrlPanel.h, hFig );
BttnHidMeas  = drawPlotProbeHiddenMeas( BttnHidMeas, CtrlPanel.h, hidMeasShow, hFig );
TmarkPanel   = drawPlotProbeTimeMarkers( TmarkPanel, CtrlPanel.h, tMarkInt, tMarkAmp, ...
                                         tMarkShow, tMarkUnits, hFig );
showHiddenObjs( 2*hidMeasShow+tMarkShow, ch, y, hData );


% Save the plot probe control panel handles
plotprobe.y                = y;
plotprobe.tHRF             = tHRF;
plotprobe.SD               = SD;
plotprobe.ch               = ch;
plotprobe.objs.CtrlPanel   = CtrlPanel;
plotprobe.objs.SclPanel    = SclPanel;
plotprobe.objs.BttnDup     = BttnDup;
plotprobe.objs.BttnHidMeas = BttnHidMeas;
plotprobe.objs.TmarkPanel  = TmarkPanel;
plotprobe.objs.Data.h      = hData;
plotprobe.objs.Figure.h    = hFig;
plotprobe.tMarkAmp         = tMarkAmp;

