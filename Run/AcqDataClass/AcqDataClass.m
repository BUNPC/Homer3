classdef AcqDataClass < matlab.mixin.Copyable
    
    methods(Abstract)
        
        % ---------------------------------------------------------
        t         = GetTime(obj)
        
        % ---------------------------------------------------------
        datamat   = GetDataMatrix(obj, idx)
        
        % ---------------------------------------------------------
        SD        = GetSD(obj)
        
        % ---------------------------------------------------------
        srcpos    = GetSrcPos(obj)
        
        % ---------------------------------------------------------
        detpos    = GetDetPos(obj)
        
        % ---------------------------------------------------------
        ml        = GetMeasList(obj)
                
        % ---------------------------------------------------------
        wls       = GetWls(obj)
        
        % ---------------------------------------------------------
        bbox      = GetSdgBbox(obj)
        
        % ---------------------------------------------------------
        s         = GetStims(obj)
        
        % ---------------------------------------------------------
        CondNames = GetCondNames(obj)
        
        % ---------------------------------------------------------
        aux       = GetAux(obj)
        
    end
    
    
    methods

        % ----------------------------------------------------------------------------------
        function varval = FindVar(obj, varname)

            if isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            elseif isproperty(obj.SD, varname)
                varval = eval( sprintf('obj.SD.%s', varname) );
            else
                varval = [];
            end
            
        end
        
    end
    
end
