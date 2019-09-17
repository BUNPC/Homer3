classdef SnirfClass < AcqDataClass & FileLoadSaveClass
        
    properties
        formatVersion
        metaDataTags
        data
        stim
        probe
        aux
    end

    properties (Access = private)
        nirs_tb;
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = SnirfClass(varargin)
            %
            % Syntax:
            %   obj = SnirfClass()
            %   obj = SnirfClass(filename);
            %   obj = SnirfClass(nirs);
            %   obj = SnirfClass(data, stim);
            %   obj = SnirfClass(data, stim, probe);
            %   obj = SnirfClass(data, stim, probe, aux);
            %   obj = SnirfClass(d, t, SD, aux, s);
            %   obj = SnirfClass(d, t, SD, aux, s, CondNames);
            %   
            %   Also for debugging/simulation of time bases 
            % 
            %   obj = SnirfClass(nirs, tfactors);
            %
            % Example 1:
            %   Nirs2Snirf('./Simple_Probe1_run04.nirs');
            %   snirf = SnirfClass('./Simple_Probe1_run04.snirf');
            %    
            %   Here's some of the output:
            %
            %   snirf(1).data ====>
            % 
            %       DataClass with properties:
            %
            %           data: [1200x8 double]
            %           time: [1200x1 double]
            %           measurementList: [1x8 MeasListClass]
            %
             
            % Initialize properties from SNIRF spec 
            obj.formatVersion = '1.10';
            obj.metaDataTags   = MetaDataTagsClass();
            obj.data           = DataClass().empty();
            obj.stim           = StimClass().empty();
            obj.probe          = ProbeClass().empty();
            obj.aux            = AuxClass().empty();
            
            % Set base class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';
            
            % See if we're loading .nirs data format
            if nargin>4
                d         = varargin{1};
                t         = varargin{2};
                SD        = varargin{3};
                aux       = varargin{4};
                s         = varargin{5};
            end
            if nargin>5
                CondNames = varargin{6};
            end
            
            % TBD: Need to find better way of parsing arguments. It gets complicated 
            % because of all the variations of calling this class constructor but 
            % there is should be a simpler way to do this 
            
            % The basic 5 of a .nirs format in a struct
            if nargin==1 || (nargin==2 && isa(varargin{2}, 'double'))
                if isa(varargin{1}, 'SnirfClass')
                    obj.Copy(varargin{1});
                    return;
                end                
                
                if ischar(varargin{1})
                    obj.Load(varargin{1});
                elseif isstruct(varargin{1})
                    tfactors = 1;    % Debug simulation parameter
                    if nargin==2
                        tfactors = varargin{2};
                    end                    
                    nirs = varargin{1};
                    obj.GenSimulatedTimeBases(nirs, tfactors);
                    for ii=1:length(tfactors)                        
                        obj.data(ii) = DataClass(obj.nirs_tb(ii).d, obj.nirs_tb(ii).t, obj.nirs_tb(ii).SD.MeasList);
                    end
                    
                    for ii=1:size(nirs.s,2)
                        if isfield(nirs, 'CondNames')
                            obj.stim(ii) = StimClass(nirs.s(:,ii), nirs.t, nirs.CondNames{ii});
                        else
                            obj.stim(ii) = StimClass(nirs.s(:,ii), nirs.t, num2str(ii));
                        end
                    end
                    obj.probe      = ProbeClass(nirs.SD);
                    for ii=1:size(nirs.aux,2)
                        obj.aux(ii) = AuxClass(nirs.aux(:,ii), nirs.t, sprintf('aux%d',ii));
                    end
                    
                    % Add metadatatags
                    obj.AddTags();
                    
                end                
            elseif nargin>1 && nargin<5
                data = varargin{1};
                obj.SetData(data);
                stim = varargin{2};
                obj.SetStim(stim);
                if nargin>2
                    probe = varargin{3};
                    obj.SetSd(probe);
                end
                if nargin>3
                    aux = varargin{4};
                    obj.SetAux(aux);
                end
                                
            % The basic 5 of a .nirs format as separate args
            elseif nargin==5
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,num2str(ii));
                end
                obj.probe      = ProbeClass(SD);
                for ii=1:size(aux,2)
                    obj.aux(ii) = AuxClass(aux, t, sprintf('aux%d',ii));
                end
                
                % Add metadatatags
                obj.AddTags();
                
            % The basic 5 of a .nirs format plus condition names
            elseif nargin==6
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,CondNames{ii});
                end
                obj.probe      = ProbeClass(SD);
                for ii=1:size(aux,2)
                    obj.aux(ii) = AuxClass(aux, t, sprintf('aux%d',ii));
                end
                
                % Add metadatatags
                obj.AddTags();
            end
            
        end
        
        
        
        % -------------------------------------------------------
        function err = Copy(obj, obj2)
            err=0;
            if ~isa(obj2, 'SnirfClass')
                err=1;
                return;
            end
            obj.formatVersion = obj2.formatVersion;
            obj.metaDataTags  = CopyHandles(obj2.metaDataTags);
            obj.data          = CopyHandles(obj2.data);
            obj.stim          = CopyHandles(obj2.stim);
            obj.probe         = CopyHandles(obj2.probe);
            obj.aux           = CopyHandles(obj2.aux);
        end
        
        
        % -------------------------------------------------------
        function objnew = CopyMutable(obj, options)
            if nargin==1
                options = '';
            end
            
            % Generate new instance of SnirfClass
            objnew = SnirfClass();
            
            % Copy mutable properties to new object instance;
            objnew.stim = CopyHandles(obj.stim);
            
            if strcmp(options, 'extended') 
                t = obj.GetTimeCombined();
                objnew.data = DataClass([],t,[]);
            end
            
        end
       
        
        
        % -------------------------------------------------------
        function SortStims(obj)
            if isempty(obj.stim)
                return;
            end
            temp = CopyHandles(obj.stim);
            delete(obj.stim);
            names = cell(length(temp),1);
            for ii=1:length(temp)
                names{ii} = temp(ii).name;
            end
            [~,idx] = sort(names);
            obj.stim = temp(idx).copy;
        end
        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fname, parent)
            err = 0;
            
            % Arg 1
            if ~exist('fname','var') || ~exist(fname,'file')
                fname = '';
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/nirs';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            % Do some error checking
            if ~isempty(fname)
                obj.filename = fname;
            else
                fname = obj.filename;
            end
            if isempty(fname)
               err=-1;
               return;
            end
            
            %%%%%%%%%%%% Ready to load from file
            
            try 
                
                %%%% Load formatVersion
                foo = convertH5StrToStr(h5read(fname, '/formatVersion'));
                if iscell(foo)
                    obj.formatVersion = foo{1};
                else
                    obj.formatVersion = foo;
                end
            
                %%%% Load metaDataTags
                if obj.metaDataTags.LoadHdf5(fname, [parent, '/metaDataTags']) < 0
                    obj.metaDataTags.delete();
                    obj.metaDataTags = [];
                    err=-1;
                    return;
                end
                
                %%%% Load data
                ii=1;
                while 1
                    if ii > length(obj.data)
                        obj.data(ii) = DataClass;
                    end
                    if obj.data(ii).LoadHdf5(fname, [parent, '/data', num2str(ii)]) < 0
                        obj.data(ii).delete();
                        obj.data(ii) = [];
                        if ii==1
                            err=-1;
                        end
                        break;
                    end
                    ii=ii+1;
                end
                
                %%%% Load stim
                
                % Since we want to load stims in sorted order (i.e., according to alphabetical order
                % of condition names), first load to temporary variable.
                ii=1;
                while 1
                    if ii > length(obj.stim)
                        obj.stim(ii) = StimClass;
                    end
                    if obj.stim(ii).LoadHdf5(fname, [parent, '/stim', num2str(ii)]) < 0
                        obj.stim(ii).delete();
                        obj.stim(ii) = [];
                        if ii==1
                            err=-1;
                        end
                        break;
                    end
                    ii=ii+1;
                end
                obj.SortStims();
                
                %%%% Load probe
                obj.probe = ProbeClass();
                obj.probe.LoadHdf5(fname, [parent, '/probe']);
                
                %%%% Load aux
                ii=1;
                while 1
                    if ii > length(obj.aux)
                        obj.aux(ii) = AuxClass;
                    end
                    if obj.aux(ii).LoadHdf5(fname, [parent, '/aux', num2str(ii)]) < 0
                        obj.aux(ii).delete();
                        obj.aux(ii) = [];
                        if ii==1
                            err=-1;
                        end
                        break;
                    end
                    ii=ii+1;
                end
            catch
                err=-1;
            end
            obj.err = err;

        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            % Arg 1
            if ~exist('fname','var') || isempty(fname)
                fname = '';
            end
            
            % Args
            if exist(fname, 'file')
                delete(fname);
            end
            fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5F.close(fid);
            
            if ~exist('parent', 'var')
                parent = '/nirs';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            %%%%% Save this object's properties
            
            % Save formatVersion
            if isempty(obj.formatVersion)
                obj.formatVersion = '1.10';
            end
            hdf5write(fname, '/formatVersion', obj.formatVersion, 'WriteMode','append');
            
            % Save metaDataTags
            obj.metaDataTags.SaveHdf5(fname, [parent, '/metaDataTags']);
            
            % Save data
            for ii=1:length(obj.data)
                obj.data(ii).SaveHdf5(fname, [parent, '/data', num2str(ii)]);
            end
            
            % Save stim
            for ii=1:length(obj.stim)
                obj.stim(ii).SaveHdf5(fname, [parent, '/stim', num2str(ii)]);
            end
            
            % Save sd
            obj.probe.SaveHdf5(fname, [parent, '/probe']);
            
            % Save aux
            for ii=1:length(obj.aux)
                obj.aux(ii).SaveHdf5(fname, [parent, '/aux', num2str(ii)]);
            end
        end
       
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;            
            if ~strcmp(obj.formatVersion, obj2.formatVersion)
                return;
            end
            if length(obj.data)~=length(obj2.data)
                return;
            end
            for ii=1:length(obj.data)
                if obj.data(ii)~=obj2.data(ii)
                    return;
                end
            end
            if length(obj.stim)~=length(obj2.stim)
                return;
            end
            for ii=1:length(obj.stim)
                flag = false;
                for jj=1:length(obj2.stim)
                    if obj.stim(ii)==obj2.stim(jj)
                        flag = true;
                        break;
                    end
                end
                if flag==false
                    return;
                end
            end
            if obj.probe~=obj2.probe
                return;
            end
            if length(obj.aux)~=length(obj2.aux)
                return;
            end
            for ii=1:length(obj.aux)
                if obj.aux(ii)~=obj2.aux(ii)
                    return;
                end
            end
            if length(obj.metaDataTags)~=length(obj2.metaDataTags)
                return;
            end
            if(obj.metaDataTags~=obj2.metaDataTags)
                return;
            end
            B = true;
        end
        
        
        % ----------------------------------------------------------------------
        function AddTags(obj)
            if isempty(fieldnames(obj.metaDataTags.metadata))
                obj.metaDataTags.Add('SubjectID','default');
                obj.metaDataTags.Add('MeasurementDate','unknown');
                obj.metaDataTags.Add('MeasurementTime','unknown');
                obj.metaDataTags.Add('LengthUnit','mm');
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Basic methods to Set/Get native variable 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ---------------------------------------------------------
        function val = GetFormatVersion(obj)
            val = obj.formatVersion;
        end
        
        % ---------------------------------------------------------
        function val = GetFormatVersionString(obj)
            val = sprintf('SNIRF v%s', obj.formatVersion);
        end
        
        % ---------------------------------------------------------
        function SetData(obj, val)
            obj.data = CopyHandles(val);            
        end
        
        % ---------------------------------------------------------
        function val = GetData(obj)
            val = obj.data;
        end
        
        % ---------------------------------------------------------
        function SetStim(obj, val)
            obj.stim = CopyHandles(val);
        end
        
        % ---------------------------------------------------------
        function val = GetStim(obj)
            val = obj.stim;
        end
        
        % ---------------------------------------------------------
        function SetSd(obj, val)
            obj.probe = CopyHandles(val);            
        end
        
        % ---------------------------------------------------------
        function val = GetSd(obj)
            val = obj.probe;
        end
        
        % ---------------------------------------------------------
        function SetAux(obj, val)
            obj.aux = CopyHandles(val);            
        end
        
        % ---------------------------------------------------------
        function val = GetAux(obj)
            val = obj.aux;
        end
        
        % ---------------------------------------------------------
        function SetMetaDataTags(obj, val)
            obj.metaDataTags = val;            
        end
        
        % ---------------------------------------------------------
        function val = GetMetaDataTags(obj)
            val = obj.metaDataTags;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods that must be implemented as a child class of AcqDataClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ---------------------------------------------------------
        function t = GetTime(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            t = obj.data(iBlk).GetTime();
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            datamat = obj.data(iBlk).GetDataMatrix();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            ml = obj.data(iBlk).GetMeasList();
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.probe.GetWls();
        end
        
        
        % ---------------------------------------------------------
        function SetStims_MatInput(obj, s, t)
            if nargin<2
                return
            end
            if isempty(t)
                return;
            end
            for ii=1:size(s,2)
                tidxs = find(s(:,ii)~=0);
                for jj=1:length(tidxs)
                    if ~obj.stim(ii).Exists(t(tidxs(jj)))
                        obj.stim(ii).AddStims(t(tidxs(jj)));
                    else
                        obj.stim(ii).EditValue(t(tidxs(jj)), s(tidxs(jj),ii));
                    end
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function s = GetStims(obj, t)
            s = zeros(length(t), length(obj.stim));
            for ii=1:length(obj.stim)
                [ts, v] = obj.stim(ii).GetStim();
                [~, k] = nearest_point(t, ts);
                if isempty(k)
                    continue;
                end
                s(k,ii) = v;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            CondNamesLocal = unique({obj.stim.name});
            stimnew = StimClass().empty;
            for ii=1:length(CondNames)
                k = find(strcmp(CondNamesLocal, CondNames{ii}));
                if ~isempty(k)
                    stimnew(ii) = StimClass(obj.stim(k));
                else
                    stimnew(ii) = StimClass(CondNames{ii});
                end
            end
            obj.stim = stimnew;
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = cell(1,length(obj.stim));
            for ii=1:length(obj.stim)
                CondNames{ii} = obj.stim(ii).GetName();
            end
        end
        
        
        
        % ---------------------------------------------------------
        function SD = GetSDG(obj)
            SD.SrcPos = obj.probe.GetSrcPos();
            SD.DetPos = obj.probe.GetDetPos();
        end
                
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            srcpos = obj.probe.GetSrcPos();
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            detpos = obj.probe.GetDetPos();
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = struct('data',[], 'names',{{}});            
            for ii=1:size(obj.aux,2)
                aux.data(:,ii) = obj.aux(ii).GetData();
                aux.names{ii} = obj.aux(ii).GetName();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = length(obj.data);
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, ich] = GetDataBlocksIdxs(obj, ich0)
            iDataBlks=[];
            ich={};
            if nargin==1
                ich0=[];
            end
            if isempty(ich0)
                iDataBlks=1:length(obj.data);
                return;
            end
            
            % Get channel matrix for whole probe
            mlAll = [];
            nDataBlks = length(obj.data);
            for iBlk = 1:nDataBlks
                mlAll = [mlAll; obj.GetMeasList(iBlk)];
            end
            
            iSrc = mlAll(ich0,1);
            iDet = mlAll(ich0,2);

            % Now search block by block for the selecdted channels
            ich = cell(nDataBlks,1);
            for iBlk=1:nDataBlks
                ml = obj.GetMeasList(iBlk);
                for ii=1:length(ich0)
                    k = find(ml(:,1)==iSrc(ii) & ml(:,2)==iDet(ii));
                    if ~isempty(k)
                        iDataBlks = [iDataBlks; iBlk];
                        ich{iBlk} = [ich{iBlk}, k(1)];
                    end
                end
            end
            
            % Important: make sure iDataBlks is row vector (: + transpose does that) .
            % For some reason a for-loop traversing through empty column vector doesn't work properly
            iDataBlks = sort(unique(iDataBlks(:)'));
            
        end

    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pubic interface for .nirs processing stream
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function d = Get_d(obj, iBlk)
            d = [];
            if isempty(obj.data)
                return;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            d = obj.data(iBlk).GetDataMatrix();
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = Get_t(obj, iBlk)
            t = [];
            if isempty(obj.data)
                return;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            t = obj.data(iBlk).GetTime();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = Get_SD(obj, iBlk)
            SD = [];
            if isempty(obj.probe)
                return;
            end
            if isempty(obj.data)
                return;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            SD.Lambda   = obj.probe.GetWls();
            SD.SrcPos   = obj.probe.GetSrcPos();
            SD.DetPos   = obj.probe.GetDetPos();
            SD.MeasList = obj.data(iBlk).GetMeasList();
            SD.MeasListAct = ones(size(SD.MeasList,1),1);
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = Get_aux(obj)
            aux = [];
            for ii=1:size(obj.aux,2)
                aux(:,ii) = obj.aux(ii).GetData();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = Get_s(obj, iBlk)
            s = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if isempty(obj.data)
                return;
            end
            t = obj.data(iBlk).GetTime();
            s = zeros(length(t), length(obj.stim));
            for ii=1:length(obj.stim)
                [ts, v] = obj.stim(ii).GetStim();
                [~, k] = nearest_point(t, ts);
                if isempty(k)
                    continue;
                end
                s(k,ii) = v;
            end
        end
        
    end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All other public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            % Try to find existing condition to which to add stims. 
            for ii=1:length(obj.stim)
                if strcmp(condition, obj.stim(ii).GetName())
                    obj.stim(ii).AddStims(tPts);
                    return;
                end
            end
            
            % Otherwise we have a new condition to which to add the stims. 
            obj.stim(end+1) = StimClass(tPts, condition);
            obj.SortStims();
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            % Find all stims for any conditions which match the time points. 
            for ii=1:length(obj.stim)
                obj.stim(ii).DeleteStims(tPts);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || isempty(condition)
                return;
            end
            
            % Find the destination condition to move stims (among the time pts in tPts)
            % to
            j = [];
            for ii=1:length(obj.stim)
                if strcmp(condition, obj.stim(ii).GetName())
                    j=ii;
                    break;
                end
            end
            
            % If no destination condition found among existing conditions,
            % then create a new condition to move stims to 
            if isempty(j)
                j = length(obj.stim)+1;
                
                % Otherwise we have a new condition to which to add the stims.
                obj.stim(j) = StimClass([], condition);
                obj.SortStims();
                
                % Recalculate j after sort
                for ii=1:length(obj.stim)
                    if strcmp(condition, obj.stim(ii).GetName())
                        j=ii;
                        break;
                    end
                end
            end

            % Find all stims for any conditions which match the time points.
            for ii=1:length(tPts)
                for kk=1:length(obj.stim)
                    d = obj.stim(kk).GetData();
                    if isempty(d)
                        continue;
                    end
                    k = find(d(:,1)==tPts(ii));
                    if ~isempty(k)
                        if kk==j
                            continue;
                        end
                        
                        % If stim at time point tPts(ii) exists in stim
                        % condition kk, then move stim from obj.stim(kk) to
                        % obj.stim(j)
                        obj.stim(j).AddStims(tPts(ii), d(k(1),2), d(k(1),3));

                        % After moving stim from obj.stim(kk) to
                        % obj.stim(j), delete it from obj.stim(kk)                 
                        d(k(1),:)=[];
                        obj.stim(kk).SetData(d);
                        
                        % Move on to next time point
                        break;
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            obj.stim(icond).SetTpts(tpts);
        end
        
        
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            if icond>length(obj.stim)
                tpts = [];
                return;
            end
            tpts = obj.stim(icond).GetTpts();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            obj.stim(icond).SetDuration(duration);
        end
        
        
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if icond>length(obj.stim)
                duration = [];
                return;
            end
            duration = obj.stim(icond).GetDuration();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimValues(obj, icond, vals)
            obj.stim(icond).SetValues(vals);
        end
        
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValues(obj, icond)
            if icond>length(obj.stim)
                vals = [];
                return;
            end
            vals = obj.stim(icond).GetValues();
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            k=[];
            for ii=1:length(obj.stim)
                if strcmp(obj.stim(ii).GetName(), oldname)
                    k = ii;
                    break;
                end
            end
            if isempty(k)
                return;
            end
            obj.stim(k).SetName(newname);
            obj.SortStims();
        end
     
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.data)
                return;
            end
            if isempty(obj.probe)
                return;
            end
            b = false;
        end
        
    end
 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
        function GenSimulatedTimeBases(obj, nirs, tfactors)
            obj.nirs_tb = struct('SD', struct('Lambda',nirs.SD.Lambda, 'MeasList',[], 'SrcPOos',[], 'DetPOos',[]), ...
                                 't',[], ...
                                 'd',[] ...
                                 );
                             
            if length(tfactors)==1 && tfactors==1
                obj.nirs_tb = nirs;
                return;
            end
            
            % a) Subdivide data and measurement list among time bases
            % b) Resample time and data
            % c) Throw out source and detectors that don't belong in each time base
            nCh = size(nirs.SD.MeasList,1)/length(nirs.SD.Lambda);
            nTimeBases = length(tfactors);
            baseSize = round(nCh/nTimeBases);
            irows = 1:baseSize:nCh;
                            
            % Assign channels for time bases
            obj.nirs_tb = repmat(obj.nirs_tb, nTimeBases,1);
            for iWl=1:length(nirs.SD.Lambda)
                iBase = 1;
                for ii=irows+(iWl-1)*nCh
                    istart = ii;
                    if ii+baseSize-1 <= iWl*nCh
                        iend = ii+baseSize-1;
                    else
                        iend = iWl*nCh;
                    end
                    nChAdd = iend-istart+1;
                    obj.nirs_tb(iBase).d(:,end+1:end+nChAdd) = nirs.d(:,istart:iend);
                    obj.nirs_tb(iBase).SD.MeasList(end+1:end+nChAdd,:) = nirs.SD.MeasList(istart:iend,:);
                    if iBase<nTimeBases
                        iBase = iBase+1;
                    end
                end
            end
            
            % Resample data time and throw out optodes that don't belong in each time base
            for iBase=1:length(obj.nirs_tb)
                % Resample time
                [n,d] = rat(tfactors(iBase));
                obj.nirs_tb(iBase).t = resample(nirs.t, n, d);

                % Resample data
                obj.nirs_tb(iBase).d = resample(obj.nirs_tb(iBase).d, n, d);
                
                % Throw out source and detectors that don't belong in each time base
                iSrc = unique(obj.nirs_tb(iBase).SD.MeasList(:,1));
                obj.nirs_tb(iBase).SD.SrcPos = nirs.SD.SrcPos(iSrc);
                iDet = unique(obj.nirs_tb(iBase).SD.MeasList(:,2));
                obj.nirs_tb(iBase).SD.DetPos = nirs.SD.DetPos(iDet);
            end
            
        end
        
    end
    
end


