function iCh = GetSelectedChannels(handles)
global maingui

iCh         = [];

datatype    = GetDatatype(handles);
iWl         = GetWl(handles);
hbType      = GetHbType(handles);
iSrcDet     = maingui.axesSDG.iSrcDet;
iCond       = GetCondition(handles); 
ml          = GetMeasurementList(handles);

for kk = 1:size(iSrcDet,1)
    for ii = 1:length(ml)
        
        if datatype == maingui.buttonVals.RAW   ||   datatype == maingui.buttonVals.OD
            
            for jj = 1:length(iWl)
                if  ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                    ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                    ml(ii).wavelengthIndex == iWl(jj)
                
                     iCh = [iCh, ii]; %#ok<*AGROW>

                end
            end
            
        elseif datatype == maingui.buttonVals.CONC
            
            for jj = 1:length(hbType)

                if ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                   ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                   strcmp(ml(ii).dataTypeLabel, hbType{jj})

                     iCh = [iCh, ii];
                     
                end
            end
            
        elseif datatype == maingui.buttonVals.OD_HRF
            
            for jj = 1:length(iWl)

                if ml(ii).sourceIndex     == iSrcDet(kk,1)   && ...
                   ml(ii).detectorIndex   == iSrcDet(kk,2)   && ...
                   ml(ii).wavelengthIndex == iWl(jj)         && ...
                   ml(ii).dataTypeIndex   == iCond

                     iCh = [iCh, ii];

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

                end
            
            end
            
        end
        
    end
end



