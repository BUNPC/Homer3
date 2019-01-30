classdef AcqDataClass < matlab.mixin.Copyable
    
    properties
        filename;
        fileformat;        
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
        function Load(obj, filename)
            switch(lower(obj.fileformat))
                case {'.mat','matlab','mat'}
                    obj.LoadMatlabFormat();
                case {'hdf','.hdf','hdf5','.hdf5','hf5','.hf5','h5','.h5'}
                    if exist('filename','var')
                        obj.LoadHdf5(filename);
                    else
                        obj.LoadHdf5();
                    end
            end
        end
               
        
        % ---------------------------------------------------------
        function Save(obj, filename)
            switch(lower(obj.fileformat))
                case {'.mat','matlab','mat'}
                    obj.SaveMatlabFormat();
                case {'hdf5','.hdf5','hf5','.hf5','h5','.h5'}
                    if exist('filename','var')
                        obj.SaveHdf5(filename);
                    else
                        obj.SaveHdf5();
                    end
            end            
        end
        
        
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
        function varval = GetVar(obj, varname)
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
        
        
        
        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
            elseif ismethod(obj,['Get', varname])
                found = true;
            elseif ismethod(obj,['Get_', varname])
                found = true;
            end
        end        
        
    end
    
end
