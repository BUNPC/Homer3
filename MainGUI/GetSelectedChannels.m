function [iCh, linecolors, linestyles, linewidths] = GetSelectedChannels(handles)
global maingui

iCh         = [];

datatype    = GetDatatype(handles);
iWl         = GetWl(handles);
hbType      = GetHbType(handles);
iSrcDet     = maingui.axesSDG.iSrcDet;
iCond       = GetCondition(handles); 
ml          = GetMeasurementList(handles);

hbTypes     = {'hbo','hbr','hbt'};

linecolorsAvailable  = maingui.axesData.linecolor;
linestylesAvailable  = {'-','--',':','-.'};
linewidthsAvailable   = [2, 2, 2.5, 2, 2];

linecolors  = zeros(length(iSrcDet)*length(hbType), 3);
linestyles  = cell(1,length(iSrcDet)*length(hbType));
linewidths  = zeros(1,length(iSrcDet)*length(hbType));
hh = 1;
for kk = 1:size(iSrcDet,1)
    for ii = 1:length(ml)
        
        if datatype == maingui.buttonVals.RAW   ||   datatype == maingui.buttonVals.OD
            
            for jj = 1:length(iWl)
                if  ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                    ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                    ml(ii).wavelengthIndex == iWl(jj)
                
                     iCh = [iCh, ii]; %#ok<*AGROW>
                     linecolors(hh, :)  = linecolorsAvailable(kk, :);
                     linestyles{hh}     = linestylesAvailable{iWl(jj)};
                     linewidths(hh)     = linewidthsAvailable(iWl(jj));
                     hh = hh+1;

                end
            end
            
        elseif datatype == maingui.buttonVals.CONC
            
            for jj = 1:length(hbType)

                if ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                   ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                   strcmp(ml(ii).dataTypeLabel, hbType{jj})

                     iCh = [iCh, ii];
                     iHb = find(strcmpi(hbTypes, hbType{jj}));
                     linecolors(hh, :)  = linecolorsAvailable(kk, :);
                     linestyles{hh}     = linestylesAvailable{iHb};
                     linewidths(hh)     = linewidthsAvailable(iHb);
                     hh = hh+1;
                     
                end
            end
            
        elseif datatype == maingui.buttonVals.OD_HRF
            
            for jj = 1:length(iWl)

                if ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                   ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                   ml(ii).wavelengthIndex == iWl(jj)         && ...
                   ml(ii).dataTypeIndex   == iCond

                     iCh = [iCh, ii];
                     linecolors(hh, :)  = linecolorsAvailable(kk, :);
                     linestyles{hh}     = linestylesAvailable{iWl(jj)};
                     linewidths(hh)     = linewidthsAvailable(iWl(jj));
                     hh = hh+1;

                end
            
            end
            
        elseif datatype == maingui.buttonVals.CONC_HRF

            for jj = 1:length(hbType)

                if ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                   ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                   (strcmpi(ml(ii).dataTypeLabel, ['hrf ', hbType{jj}]) || ...
                   strcmpi(ml(ii).dataTypeLabel, [hbType{jj}, ' hrf']))     && ...
                   ml(ii).dataTypeIndex   == iCond

                     iCh = [iCh, ii];
                     iHb = find(strcmpi(hbTypes, hbType{jj}));
                     linecolors(hh, :)  = linecolorsAvailable(kk, :);
                     linestyles{hh}     = linestylesAvailable{iHb}; %#ok<*FNDSB>
                     linewidths(hh)     = linewidthsAvailable(iHb);
                     hh = hh+1;

                end
            
            end
            
        end
        
    end
end



