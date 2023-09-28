function [linecolors, linestyles, linewidths] = SetDataPlotLineStyles(handles, iCh)
global maingui

datatype    = GetDatatype(handles);
ml          = GetMeasurementList(handles);

linecolorsAvailable  = maingui.axesData.SDPairColors;
linestylesAvailable  = {'-',':','-.','--'};
linewidthsAvailable   = [1.5, 2.0, 1.5, 1.5, 1.5];

linecolors  = zeros(length(iCh), 3);
linestyles  = cell(1, length(iCh));
linewidths  = zeros(1, length(iCh));

for ii = 1:length(iCh)
    
    if datatype == maingui.buttonVals.RAW   ||   datatype == maingui.buttonVals.OD
        iSD = GetSelectedSDPairIndex(ml(iCh(ii),1), ml(iCh(ii),2));
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{ml(iCh(ii),4)};
        linewidths(ii)     = linewidthsAvailable(ml(iCh(ii),4));
        
    elseif datatype == maingui.buttonVals.CONC
                        
        iHb = ml(iCh(ii),4);
        iSD = GetSelectedSDPairIndex(ml(iCh(ii),1), ml(iCh(ii),2));
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{iHb};
        linewidths(ii)     = linewidthsAvailable(iHb);        
        
    elseif datatype == maingui.buttonVals.OD_HRF
        
        iSD = GetSelectedSDPairIndex(ml(iCh(ii),1), ml(iCh(ii),2));
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{ml(iCh(ii),4)};
        linewidths(ii)     = linewidthsAvailable(ml(iCh(ii),4));
        
    elseif datatype == maingui.buttonVals.CONC_HRF
        
        iHb = ml(iCh(ii),4);
        iSD = GetSelectedSDPairIndex(ml(iCh(ii),1), ml(iCh(ii),2));
        linecolors(ii, :)  = linecolorsAvailable(iSD, :);
        linestyles{ii}     = linestylesAvailable{iHb};
        linewidths(ii)     = linewidthsAvailable(iHb);
        
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


