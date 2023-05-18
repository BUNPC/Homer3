classdef AcqDataClass < matlab.mixin.Copyable
       
    properties (Access = public)
        bids
    end
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
        s         = GetStim(obj)

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
        function obj = AcqDataClass(fileobj)
            if nargin == 0
                return
            end
            if iscell(fileobj)
                if ~isempty(fileobj)
                    fileobj = fileobj{1};
                end
            end
            if ~ischar(fileobj)
                fileobj = '';
            end
        end


        
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
        function err = LoadBids(obj, fileobj)
            err = obj.LoadStimOverride(fileobj);
        end
        

        
        % -------------------------------------------------------
        function status = LoadStimOverride(obj, fileobj)
            global cfg
            status = false;
            cfg = InitConfig(cfg);
            if strcmpi(cfg.GetValue('Load Stim From TSV File'), 'no')
                return
            end
            obj.bids = struct('stim',{{}});            
            if isempty(fileobj)
                return
            end
            [p,f] = fileparts(fileobj);
            if isempty(p)
                p = filesepStandard(pwd);
            end
            k = strfind(f, '_nirs');
            if isempty(k)
                k = length(f)+1;
            end
            fnameTsv = [filesepStandard(p), f(1:k-1), '_events.tsv'];
            file = mydir(fnameTsv);
            if isempty(file)
                return
            end
            [obj.bids.stim, err] = readTsv([filesepStandard(p), file(1).name],'numstr2num');
%             if err < 0
%                 obj.SetError(-8);
%                 return;
%             end
            if isempty(obj.bids.stim)
                return
            end
            s = TsvFile2Snirf(obj.bids.stim);
            obj.stim = s.stim.copy();
            status = true;
        end
        
        
        
        % -------------------------------------------------------
        function err = ReloadStim(obj, fileobj)
            err = 0;
            obj.bids = struct('stim',{{}});            
            if isempty(fileobj)
                return
            end
            [p,f] = fileparts(fileobj);
            if isempty(p)
                p = filesepStandard(pwd);
            end
            k = strfind(f, '_nirs');
            if isempty(k)
                k = length(f)+1;
            end
            fnameTsv = [filesepStandard(p), f(1:k-1), '_events.tsv'];
            file = mydir(fnameTsv);
            if isempty(file)
                return
            end
            obj.bids.stim = readTsv([filesepStandard(p), file(1).name],'numstr2num');
            s = TsvFile2Snirf(obj.bids.stim);
            obj.stim = s.stim.copy();
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
        
        
        
        % ----------------------------------------------------------------------------------
        function fnameTsv = GetStimTsvFilename(obj)
            fnameTsv = '';
            [pname, fname] = fileparts(obj.GetFilename());
            k = strfind(fname, '_nirs');
            if isempty(k)
                k = length(fname)+1;
            end
            if isempty(fname)
                return;
            end
            fnameTsv = [filesepStandard(pname), fname(1:k-1), '_events.tsv'];
        end
                
    end
    
end
