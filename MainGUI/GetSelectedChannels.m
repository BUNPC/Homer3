function iCh = GetSelectedChannels(handles)
global maingui

iCh         = [];

datatype    = GetDatatype(handles);
iWl         = GetWl(handles);
[~, hbTypeIdx] = GetHbType(handles);
iSrcDet     = maingui.axesSDG.iSrcDet;
iCond       = GetCondition(handles); 
ml          = GetMeasurementList(handles);

for kk = 1:size(iSrcDet,1)
    for ii = 1:length(ml)
        
        if datatype == maingui.buttonVals.RAW   ||   datatype == maingui.buttonVals.OD
            
            for jj = 1:length(iWl)
                if  ml(ii,1) == iSrcDet(kk,1)   && ...
                    ml(ii,2) == iSrcDet(kk,2)   && ...
                    ml(ii,4) == iWl(jj)
                
                     iCh = [iCh, ii]; %#ok<*AGROW>

                end
            end
            
        elseif datatype == maingui.buttonVals.CONC
            
            for jj = 1:length(hbTypeIdx)

                if ml(ii,1) == iSrcDet(kk,1)   && ...
                   ml(ii,2) == iSrcDet(kk,2)   && ...
                   ml(ii,4) == hbTypeIdx(jj)

                     iCh = [iCh, ii];
                     
                end
            end
            
        elseif datatype == maingui.buttonVals.OD_HRF
            
            for jj = 1:length(iWl)

                if ml(ii,1) == iSrcDet(kk,1)   && ...
                   ml(ii,2) == iSrcDet(kk,2)   && ...
                   ml(ii,4) == iWl(jj)         && ...
                   ml(ii,3) == iCond

                     iCh = [iCh, ii];

                end
            
            end
            
        elseif datatype == maingui.buttonVals.CONC_HRF

            for jj = 1:length(hbTypeIdx)

                if ml(ii,1) == iSrcDet(kk,1)    && ...
                   ml(ii,2) == iSrcDet(kk,2)    && ...
                   ml(ii,4) == hbTypeIdx(jj)    && ...
                   ml(ii,3) == iCond

                     iCh = [iCh, ii];

                end
            
            end
            
        end
        
    end
end



