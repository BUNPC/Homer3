classdef AcqDataClass < matlab.mixin.Copyable
    
    properties
        filename;
    end
    
    
    methods(Abstract)
        
        % ---------------------------------------------------------
        t         = GetTime(obj, idx)
        
        % ---------------------------------------------------------
        datamat   = GetDataMatrix(obj, idx)
        
        % ---------------------------------------------------------
        SD        = GetSD(obj)
        
        % ---------------------------------------------------------
        srcpos    = GetSrcPos(obj)
        
        % ---------------------------------------------------------
        detpos    = GetDetPos(obj)
        
        % ---------------------------------------------------------
        ml        = GetMeasList(obj, idx)
                
        % ---------------------------------------------------------
        wls       = GetWls(obj)
        
        % ---------------------------------------------------------
        bbox      = GetSdgBbox(obj)
        
        % ---------------------------------------------------------
        SetStims(obj, s)
        
        % ---------------------------------------------------------
        s         = GetStims(obj)
        
        % ---------------------------------------------------------
        SetCondNames(obj, CondNames)
        
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
