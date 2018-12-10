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
        SetStims_MatInput(obj, s, t, CondNames)
        
        % ---------------------------------------------------------
        s         = GetStims(obj)
        
        % ---------------------------------------------------------
        SetConditions(obj, CondNames)
        
        % ---------------------------------------------------------
        CondNames = GetConditions(obj)
        
        % ---------------------------------------------------------
        aux       = GetAuxiliary(obj)
        
        % ---------------------------------------------------------
        SetStimDuration(obj, icond, duration);
        
        % ---------------------------------------------------------
        duration = GetStimDuration(obj, icond)
        
    end
    
    
    methods

        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            optpos = [obj.GetSrcPos(); obj.GetDetPos()];
            
            xmin = min(optpos(:,1));
            xmax = max(optpos(:,1));
            ymin = min(optpos(:,2));
            ymax = max(optpos(:,2));
            
            width = xmax-xmin;
            height = ymax-ymin;
            
            px = width * 0.10; 
            py = height * 0.10; 

            bbox = [xmin-px, xmax+px, ymin-py, ymax+py];
        end
        
        
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
