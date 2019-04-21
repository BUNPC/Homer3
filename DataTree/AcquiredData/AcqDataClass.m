classdef AcqDataClass < matlab.mixin.Copyable
       
    methods(Abstract)
        
        % ---------------------------------------------------------
        t         = GetTime(obj, iBlk)
        
        % ---------------------------------------------------------
        datamat   = GetDataMatrix(obj, iBlk)
        
        % ---------------------------------------------------------
        SD        = GetSDG(obj)
        
        % ---------------------------------------------------------
        srcpos    = GetSrcPos(obj)
        
        % ---------------------------------------------------------
        detpos    = GetDetPos(obj)
        
        % ---------------------------------------------------------
        ml        = GetMeasList(obj, iBlk)
                

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
        duration = GetStimDuration(obj, icond);
        
        % ---------------------------------------------------------
        n = GetDataBlocksNum(obj);

        % ---------------------------------------------------------
        [iDataBlks, ich] = GetDataBlocksIdxs(obj, ich);
        
        % ---------------------------------------------------------
        params = MutableParams(obj);
        
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
        function varval = GetVar(obj, varname)
            if ismethod(obj,['Get_', varname])
                varval = eval( sprintf('obj.Get_%s()', varname) );
            elseif ismethod(obj,['Get', varname])
                varval = eval( sprintf('obj.Get%s()', varname) );
            elseif isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            else
                varval = [];
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function obj2 = Copy(obj)
            % Create instance of acquired data class by doing a shallow
            % copy. We don't need a deep copy here because we will 
            % do that further down in the function only for the mutable
            % properties.
            obj2 = obj.copy;
            
            % Deep copy mutable properties from obj to obj2
            for ii=1:length(obj.mutable)
                if isa( eval( sprintf('obj.%s', obj.mutable{ii}) ), 'handle')
                    nProp = eval( sprintf('length(obj.%s(:));', obj.mutable{ii}) );
                    constructorName = sprintf('%sClass', [upper(obj.mutable{ii}(1)), obj.mutable{ii}(2:end)] );
                    for kk=1:nProp
                        eval( sprintf('obj2.%s(kk) = %s(obj.%s(kk));', obj.mutable{ii}, constructorName, obj.mutable{ii}) );
                    end
                else
                    eval( sprintf('obj2.%s = obj.%s;', obj.mutable{ii}, obj.mutable{ii}) );
                end
            end
                        
        end
        
        
        % ----------------------------------------------------------------------------------
        function props = properties_mutable(obj)
            props = obj.mutable;
        end        
        
    end
    
end
