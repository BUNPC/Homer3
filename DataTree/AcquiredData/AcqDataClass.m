classdef AcqDataClass < matlab.mixin.Copyable
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % These methods must be implemented in any derived class
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        objnew = CopyMutable(obj);

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
        function t = GetTimeCombined(obj)
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
