function [linecolors, linestyles, linewidths] = SetDataPlotLineStyles(handles, iCh)
global maingui

datatype    = GetDatatype(handles);
ml          = GetMeasurementList(handles);

linecolorsAvailable  = maingui.axesData.SDPairColors;
linestylesAvailable  = {'-','--',':','-.'};
linewidthsAvailable   = [2, 2, 2.5, 2, 2];

linecolors  = zeros(length(iCh), 3);
linestyles  = cell(1, length(iCh));
linewidths  = zeros(1, length(iCh));

kk = 1;
for ii = 1:length(iCh)
    
    if datatype == maingui.buttonVals.RAW   ||   datatype == maingui.buttonVals.OD
        iSD = GetSelectedSDPairIndex(ml(iCh(ii)).sourceIndex, ml(iCh(ii)).detectorIndex);
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{ml(iCh(ii)).wavelengthIndex};
        linewidths(ii)     = linewidthsAvailable(ml(iCh(ii)).wavelengthIndex);
        kk = kk+1;
        
    elseif datatype == maingui.buttonVals.CONC
                        
        iHb = HbLabel2Index(ml(iCh(ii)).dataTypeLabel);
        if isempty(iHb)
            iHb = 1;
        end
        iSD = GetSelectedSDPairIndex(ml(iCh(ii)).sourceIndex, ml(iCh(ii)).detectorIndex);
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{iHb};
        linewidths(ii)     = linewidthsAvailable(iHb);        
        kk = kk+1;
        
    elseif datatype == maingui.buttonVals.OD_HRF
        
        iSD = GetSelectedSDPairIndex(ml(iCh(ii)).sourceIndex, ml(iCh(ii)).detectorIndex);
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{ml(iCh(ii)).wavelengthIndex};
        linewidths(ii)     = linewidthsAvailable(ml(iCh(ii)).wavelengthIndex);
        kk = kk+1;
        
    elseif datatype == maingui.buttonVals.CONC_HRF
        
        iHb = HbLabel2Index(ml(iCh(ii)).dataTypeLabel);
        if isempty(iHb)
            iHb = 1;
        end
        iSD = GetSelectedSDPairIndex(ml(iCh(ii)).sourceIndex, ml(iCh(ii)).detectorIndex);
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{iHb};
        linewidths(ii)     = linewidthsAvailable(iHb);
        kk = kk+1;
        
    end
    
end




% --------------------------------------------------------------------------
function iHb = HbLabel2Index(label)
hbTypes     = {'hbo','hbr','hbt'};
iHb = [];
for jj = 1:length(hbTypes)
    if ~includes(lower(label), lower(hbTypes{jj}))
        continue;
    end
    iHb = jj;
    break;
end


