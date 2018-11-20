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
        SD        = GetSDG(obj)
        
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
        SetStims_MatInput(obj, s, t, CondNames)
        
        % ---------------------------------------------------------
        s         = GetStims(obj)
        
        % ---------------------------------------------------------
        SetConditions(obj, CondNames)
        
        % ---------------------------------------------------------
        CondNames = GetConditions(obj)
        
        % ---------------------------------------------------------
        aux       = GetAuxiliary(obj)
        
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
