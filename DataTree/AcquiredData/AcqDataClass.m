classdef AcqDataClass < matlab.mixin.Copyable
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % These methods must be implemented in any derived class
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Abstract)
        
        % ---------------------------------------------------------
        objnew    = GetFormatVersion(obj, options);

        % ---------------------------------------------------------
        val       = GetFormatVersionString(obj);
   
        % ---------------------------------------------------------
        t         = GetTime(obj, iBlk)
       
        % ---------------------------------------------------------
        datamat   = GetDataTimeSeries(obj, options, iBlk)
        
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
        s         = GetStims(obj, t)

        % ---------------------------------------------------------
        CondNames = GetConditions(obj)


        % ---------------------------------------------------------
        SetConditions(obj, CondNames)
        
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
        objnew = CopyMutable(obj, options);

    end
    
    
    methods
        
        % -------------------------------------------------------
        function b = Error(obj)
            if obj.err<0
                b = true;
            elseif obj.err==0
                b = false;
            else
                b = true;
            end
        end
        
        
        % -------------------------------------------------------
        function FreeMemory(obj, filename)
            if ~exist('filename','var')
                filename = '';
            end
            if isempty(filename)
                return;
            end            
            obj.Initialize();
        end
        
        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            optpos = [obj.GetSrcPos(); obj.GetDetPos()];
            
            xmax = max(optpos(:,1));
            ymax = max(optpos(:,2));

            xmin = min(optpos(:,1));
            ymin = min(optpos(:,2));
            
            width = xmax-xmin;
            height = ymax-ymin;
            
            if width==0
                width = 1;
            end
            if height==0
                height = 1;
            end
            
            px = width * 0.05; 
            py = height * 0.05; 

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
            
            % If varval is a class object with an IsEmpty() method and length of varval is one or 
            % less, then use it determine whether it's valid. If not, return empty as if it were 
            % really empty. This is useful when we want to copy only part of an object to save on space. 
            % For instance to reconstruct nirs style 's' variable from a SNIRF stim object we need the t 
            % property from a SNIRF data container, but we only need that one property not the whole thing
            % so we initilize only the t property. We don't want this partially initialized data object 
            % to be found (by GetVar) and used directly in the proc stream processing, we only want to use 
            % indirectly to retrieve s from stim. So we do this check to see if it's valid. It won't be 
            % since it's only partially initialized.
            if isa(varval, 'handle') && ismethod(varval,'IsEmpty')
                if length(varval)==1 && varval(1).IsEmpty()
                    varval = [];
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = GetTimeCombined(obj)
            % Function combines the time vectors for all data blocks into one time vectors. 
            t = obj.GetTime(1);
            tStart = t(1);
            tEnd   = t(end);
            tStep  = mean(diff(t));
            
            nBlks = obj.GetDataBlocksNum();
            for iBlk=2:nBlks
                t = obj.GetTime(iBlk);
                if t(1) < tStart
                    tStart = t(1);
                end
                if t(end) > tEnd
                    tEnd = t(end);
                end
                if mean(diff(t)) < tStep
                    tStep = mean(diff(t));
                end
            end
            t = tStart:tStep:tEnd;            
        end
        
                
    end
    
end
