classdef AcqDataClass < matlab.mixin.Copyable
       
    properties (Access = private)
        logger
    end
    properties (Access = protected)
        errmsgs
    end
    
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
        SD        = GetSDG(obj,option)

        % ---------------------------------------------------------
        srcpos    = GetSrcPos(obj,option)

        % ---------------------------------------------------------
        detpos    = GetDetPos(obj,option)
        
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
        function Initialize(obj)
            global logger
            obj.logger = InitLogger(logger);
        end
        
        
        % -------------------------------------------------------
        function err = Error(obj)
            err = obj.GetError();
        end
        
        
        % ---------------------------------------------------------
        function msg = GetErrorMsg(obj)
            msg = '';
            if isempty(obj)
                msg = 'AcqDataClass object is empty';
                return;
            end
            if isempty(obj.errmsgs)
                return;
            end
            if ~obj.GetError()
                return;
            end
            msg = obj.errmsgs{abs(obj.GetError())};
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
            bbox = [];
            
            optpos = [obj.GetSrcPos('2D'); obj.GetDetPos('2D')];
            if isempty(optpos)
                return
            end
            
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
        
                
        % ----------------------------------------------------------------------------------
        function data = GetStimData(~, ~)
            data = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = GetStimDataLabels(~, ~)
            val = {};
        end
                        
        
        % ----------------------------------------------------------------------------------
        function b = equal(obj, obj2)
            b = true;
            if isempty(obj.GetFilename)
                return;
            end
            if isempty(obj2.GetFilename)
                return;
            end
            [~, fname1, ext1] = fileparts(obj.GetFilename);
            [~, fname2, ext2] = fileparts(obj2.GetFilename);            
            if ~strcmpi([fname1, ext1], [fname2, ext2])
                b = false;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function status = Mismatch(obj, obj2)
            status = 0;
            msg = {};
            if ~exist('obj2','var')
                return;
            end
            if ~obj.equal(obj2)
                [~, fname, ext] = fileparts(obj.GetFilename);
                msg{1} = sprintf('WARNING: The acquisition file "%s" does not match the derived data in this group folder. ', [fname, ext]);
                msg{2} = sprintf('Are you sure this acquisition file belongs in this group folder?');
                obj.logger.Write([msg{:}])
            end
        end
        
        
        
    end
    
end
