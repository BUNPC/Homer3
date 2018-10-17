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
            elseif ismethod(obj,['Get', varname])
                varval = eval( sprintf('obj.Get%s()', varname) );
            elseif ismethod(obj,['Get_', varname])
                varval = eval( sprintf('obj.Get_%s()', varname) );                
            else
                varval = [];
            end
            
        end
        
    end
    
end
