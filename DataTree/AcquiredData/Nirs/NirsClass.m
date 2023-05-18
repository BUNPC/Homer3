classdef NirsClass < AcqDataClass & FileLoadSaveClass
    
    properties
        SD
        t
        s
        d
        aux
        CondNames
    end
    
    % Properties not part of the NIRS format. These parameters aren't loaded or saved to nirs files
    properties (Access = private)
        errmargin
    end
    
    methods
        
        % ---------------------------------------------------------
        function obj = NirsClass(varargin)
            %
            % Syntax:
            %   obj = NirsClass()
            %   obj = NirsClass(filename);
            %   obj = NirsClass(filename, dataStorageScheme);
            %   obj = NirsClass(SD);
            %   obj = NirsClass(SD, dataStorageScheme);
            %
            %
            % Example 1:
            %   nirs = NirsClass('./s1/neuro_run01.nirs')
            %
            %   Here's some of the output:
            %
            %       nirs ==>
            %
            %           NirsClass with properties:
            %
            %                      SD: [1x1 struct]
            %                       t: [12698x1 double]
            %                       s: [12698x2 double]
            %                       d: [12698x18 double]
            %                     aux: [12698x1 double]
            %               CondNames: {'1'  '2'}
            %                filename: './s1/neuro_run01.nirs'
            %              fileformat: 'mat'
            %         supportedFomats: [1x1 struct]
            %                     err: 0
            %
            
            % Initialize Nirs public properties
            obj.Initialize();
            
            % Set base class properties not part of NIRS format
            obj.SetFilename('');
            obj.SetFileFormat('mat');
            obj.errmargin = 1e-3;
            
            if nargin==0
                return;
            end
            
            % Else we have at least 1 input arg
            if isa(varargin{1}, 'NirsClass')
                obj.Copy(varargin{1});
            elseif isstruct(varargin{1})
                if isfield(varargin{1}, 'd') && isfield(varargin{1}, 'SD')
                    obj.CopyStruct(varargin{1})                    
                elseif isfield(varargin{1}, 'DetPos') && isfield(varargin{1}, 'SrcPos')
                    obj.CopyProbe(varargin{1})
                end
            elseif isa(varargin{1}, 'SnirfClass')
                obj.ConvertSnirf(varargin{1});
            end

            if ~ischar(varargin{1}) && nargin==1
                obj.ErrorCheck();
                return
            end
            
            if nargin==2
                obj.SetDataStorageScheme(varargin{2});
            end
            
            filename = varargin{1};
            if ~exist('filename','var') || ~exist(filename,'file')
                obj = NirsClass.empty();
                return;
            end
            obj.SetFilename(filename);
            
            % Conditional loading of snirf file data
            if strcmpi(obj.GetDataStorageScheme(), 'memory')
                obj.Load(filename);
            end
            obj.ErrorCheck();
        end
        
        
        % -------------------------------------------------------
        function Initialize(obj)
            Initialize@AcqDataClass(obj);
            
            obj.SD        = obj.InitProbe();
            obj.t         = [];
            obj.s         = [];
            obj.d         = [];
            obj.aux       = [];
            obj.CondNames = {};
            
            
            % Initialize non-.nirs variables
            obj.errmsgs = {
                'MATLAB could not load the file.'
                '''d'' is invalid.'
                '''t'' is invalid.'
                '''SD'' is invalid.'
                '''aux'' is invalid.'
                '''s'' is invalid.'
                'WARNING: ''data'' corrupt and unusable'                
                'error unknown.'
                };
            
        end
        
        
        % ---------------------------------------------------------
        function SortStims(obj)
            [~,idx] = sort(obj.CondNames);
            obj.CondNames = obj.CondNames(idx);
            obj.s = obj.s(:,idx);
        end
        
        
        % ---------------------------------------------------------
        function SortData(obj)
            [obj.SD.MeasList, order] = sortrows(obj.SD.MeasList);
            obj.d = obj.d(:,order);
            [obj.SD.MeasList, order] = sortrows(obj.SD.MeasList,4);
            obj.d = obj.d(:,order);
        end
        
        
        % ---------------------------------------------------------
        function err = LoadMat(obj, fname, ~)
            err = 0;
            
            try
                % Arg 1
                if ~exist('fname','var') || ~exist(fname,'file')
                    fname = '';
                end
                
                % Do some error checking
                if ~isempty(fname)
                    obj.SetFilename(fname);
                else
                    fname = obj.GetFilename();
                end
                if exist(fname, 'file') ~= 2
                    err = -1;
                    return;
                end
                
                % Don't reload if not empty
                if ~obj.IsEmpty()
                    err = obj.GetError();     % preserve error state if exiting early
                    return;
                end
                
                warning('off', 'MATLAB:load:variableNotFound');
                fdata = load(fname,'-mat', 'SD','t','d','s','aux','CondNames');
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % NOTE: Optional fields have positive error codes if they are
                % missing, but negative error codes if they're not missing but
                % invalid
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                % Mandatory fields
                err = obj.LoadRawData(fdata, err);
                err = obj.LoadTime(fdata, err);
                err = obj.LoadProbeMeasList(fdata, err);
                
                % Optional fields
                err = obj.LoadAux(fdata, err);
                err = obj.LoadStim(fdata, err);
                
            catch
                
                
            end
            warning('on', 'MATLAB:load:variableNotFound');
            
        end
        
        
        
        % ---------------------------------------------------------
        function err = LoadRawData(obj, fdata, err)
            if isproperty(fdata,'d')
                obj.d = fdata.d;
                if isempty(obj.d) && err == 0
                    err = -2;
                end
            elseif err == 0
                err = -2;
            end
        end
        
        
        % ---------------------------------------------------------
        function err = LoadTime(obj, fdata, err)
            if nargin == 1
                fdata = load(obj.GetFilename(),'-mat', 't');
                err = 0;
                return
            elseif nargin == 2
                err = 0;
            end
            
            if isproperty(fdata,'t') && isproperty(fdata,'d') 
                obj.t = fdata.t;
                if ~isempty(obj.t)
                    obj.errmargin = min(diff(obj.t))/10;
                elseif err == 0
                    err = -3;
                end
                if length(fdata.t) ~= size(fdata.d,1) && err == 0
                    err = -3;
                end
            elseif err == 0
                err = -3;
            end
        end
        
        
        % ---------------------------------------------------------
        function err = LoadProbeMeasList(obj, fdata, err)
            if isproperty(fdata,'SD')
                obj.CopyProbe(fdata.SD);
                if isempty(obj.SD) && err == 0
                    err = -4;
                end
            elseif err == 0
                err = -4;
            end
        end
        
        
        % ---------------------------------------------------------
        function err = LoadAux(obj, fdata, err)
            if isproperty(fdata,'aux')
                obj.aux = fdata.aux;
            elseif err==0
                err = 5;
            end
        end
        
        
        
        % ---------------------------------------------------------
        function err = LoadStim(obj, fdata, err)
            if ischar(fdata)
                fname = fdata;
                
                % Do some error checking
                if ~isempty(fname)
                    obj.SetFilename(fname);
                else
                    fname = obj.GetFilename();
                end
                if exist(fname, 'file') ~= 2
                    err = -1;
                    return;
                end
                warning('off', 'MATLAB:load:variableNotFound');
                fdata = load(fname,'-mat', 's','CondNames','t');
            end
            
            if ~isproperty(fdata,'s')
                if err==0
                    err = 6;
                end
                return;
            end
            
            obj.s = fdata.s;
            if size(fdata.s,1) ~= size(fdata.t)
                if err==0
                    err = -6;
                end
                return;
            end
            if isproperty(fdata,'CondNames')
                obj.CondNames = fdata.CondNames;
                if size(fdata.s,2) ~= length(fdata.CondNames)
                    if err==0
                        err = -6;
                    end
                    return;
                end
            else
                obj.InitCondNames();
            end
            
        end
        
        
        
        % ---------------------------------------------------------
        function SaveMat(obj, fname, options)
            if ~exist('fname','var') || isempty(fname)
                fname = '';
            end
            if ~exist('options','var') || isempty(options)
                options = 'normal';
            end
            if isempty(fname)
                fname = obj.GetFilename();
            end
            
            [str, fields] = obj.Properties2String();
            for ii = 1:length(fields)
                eval( sprintf('%s = obj.%s;', fields{ii}, fields{ii}) );
            end
            
            if ~ispathvalid(fname)
                p = fileparts(fname);
                if ~isempty(p) && ~ispathvalid(p, 'dir')
                    mkdir(p);
                end
                eval( sprintf('save(fname, ''-mat'', %s)', str) );
            elseif optionExists(options, 'normal')
                save(fname, '-mat', '-append', 'SD','s','CondNames');
            elseif optionExists(options, 'overwrite')
                eval( sprintf('save(fname, ''-mat'', %s)', str) );
            end
        end
        

        
        % -------------------------------------------------------
        function b = ProbeEqual(obj, obj2)
            b = false;
                        
            fields{1} = propnames(obj.SD);
            fields{2} = propnames(obj2.SD);
            
            fieldsToExclude = { ...
                'MeasList'; ...
                'MeasListAct'; ...
                'SrcMap'; ...
                };
            
            
            % Check MeasList explicitely
            if (isfield(obj.SD,'MeasList') && ~isfield(obj2.SD,'MeasList')) || ~isfield(obj.SD,'MeasList') && isfield(obj2.SD,'MeasList')
                return;
            end
            [~, k1] = sortrows(obj.SD.MeasList);
            [~, k2] = sortrows(obj2.SD.MeasList);
            if ~all(obj.SD.MeasList(k1,:) == obj2.SD.MeasList(k2,:))
                return;
            end            

            
            for kk = 1:length(fields)
                for jj = 1:length(fields{kk})
                    field = fields{kk}{jj};
                    
                    % Skip excluded fields
                    if ~isempty(find(strcmp(fieldsToExclude, field))) %#ok<EFIND>
                        continue;
                    end                    
                    
                    % Now compare field
                    if (isfield(obj.SD,field) && ~isfield(obj2.SD,field)) || ~isfield(obj.SD,field) && isfield(obj2.SD,field) 
                        return;
                    end
                    if eval( sprintf('~strcmp(class(obj.SD.%s), class(obj2.SD.%s))', field, field) )
                        return;
                    end
                    if eval( sprintf('length(obj.SD.%s) ~= length(obj2.SD.%s)', field, field) )
                        return;
                    end
                    EPS = 1.0e-10; %#ok<NASGU>
                    if eval( sprintf('iscell(obj.SD.%s)', field) )
                        N = eval( sprintf('length(obj.SD.%s(:))', field) );
                        for ii = 1:N
                            if eval( sprintf('length(obj.SD.%s{ii}(:)) ~= length(obj2.SD.%s{ii}(:))', field, field) )
                                return;
                            end
                            if eval( sprintf('~all(obj.SD.%s{ii}(:) == obj2.SD.%s{ii}(:))', field, field) )
                                return;
                            end
                        end
                    elseif eval( sprintf('isstruct(obj.SD.%s)', field) )
                        if eval( sprintf('~isempty(comp_struct(obj.SD.%s, obj2.SD.%s))', field, field) )
                            return;
                        end
                    else
                        if eval( sprintf('~all( abs(obj.SD.%s(:) - obj2.SD.%s(:)) < EPS )', field, field) )
                            return;
                        end
                    end
                end
            end
            b = true;
        end
        
        
        
        % --------------------------------------------------------------------
        function b = EqualStim(obj, obj2)
            b = false;
            if length(obj.s) ~= length(obj2.s)
                return;
            end
            if ~all(obj.s(:) == obj2.s(:))
                return;
            end            
            b = true;
        end
        
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            
            if length(obj.t) ~= length(obj2.t)
                return;
            end
            if ~all(obj.t == obj2.t)
                return;
            end
            
            if length(obj.d) ~= length(obj2.d)
                return;
            end
            if ~all(obj.d(:) == obj2.d(:))
                return;
            end
            
            if ~obj.ProbeEqual(obj2)
                return;
            end
            
            if length(obj.s) ~= length(obj2.s)
                return;
            end
            if ~all(obj.s(:) == obj2.s(:))
                return;
            end
            
            if length(obj.aux) ~= length(obj2.aux)
                return;
            end
            if ~all(obj.aux(:) == obj2.aux(:))
                return;
            end
            
            B = true;
        end
        
        
        
        % ---------------------------------------------------------
        function err = Copy(obj, obj2)
            err=0;
            if ~isa(obj2, 'NirsClass')
                err=1;
                return;
            end
            if obj.Mismatch(obj2)
                return;
            end
            obj.SD         = obj2.SD;
            obj.t          = obj2.t;
            obj.d          = obj2.d;
            obj.s          = obj2.s;
            obj.aux        = obj2.aux;
            obj.CondNames  = obj2.CondNames;
        end
        
        
        
        % -------------------------------------------------------
        function objnew = CopyMutable(obj, ~)
            
            % If we're working off the snirf file instead of loading everything into memory
            % then we have to load stim here from file before accessing it.
            if strcmpi(obj.GetDataStorageScheme(), 'files')
                obj.LoadStim(obj.GetFilename(), 0);
            end
            
            % Generate new instance of NirsClass
            objnew = NirsClass();
            
            % Copy mutable properties to new object instance;
            objnew.SD         = obj.SD;

            % Always sort stimulus conditions and associated stims
            % to have a predictable order for display
            objnew.s          = obj.s;            
            objnew.CondNames  = obj.CondNames;
            objnew.SortStims();
        end
        
        
        
        % ---------------------------------------------------------
        function nTrials = InitCondNames(obj)
            if isempty(obj.CondNames)
                obj.CondNames = repmat({''},1,size(obj.s,2));
            end
            for ii=1:size(obj.s,2)
                if isempty(obj.CondNames{ii})
                    % Make sure not to duplicate a condition name
                    jj=0;
                    kk=ii+jj;
                    condName = num2str(kk);
                    while ~isempty(find(strcmp(condName, obj.CondNames))) %#ok<EFIND>
                        jj=jj+1;
                        kk=ii+jj;
                        condName = num2str(kk);
                    end
                    obj.CondNames{ii} = condName;
                else
                    % Check if CondNames{ii} has a name. If not name it but
                    % make sure not to duplicate a condition name
                    k = find(strcmp(obj.CondNames{ii}, obj.CondNames));
                    if length(k)>1
                        % Unname and then rename duplicate condition
                        obj.CondNames{ii} = '';
                        
                        jj=0;
                        while find(strcmp(num2str(ii), obj.CondNames))
                            kk=ii+jj;
                            obj.CondNames{ii} = num2str(kk);
                            jj=jj+1;
                        end
                    end
                end
            end
            nTrials = sum(obj.s,1);
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.SD)
                return;
            end
            if isempty(obj.SD.SrcPos)
                return;
            end
            if isempty(obj.SD.DetPos)
                return;
            end
            if isempty(obj.SD.MeasList)
                return;
            end
            if isempty(obj.t)
                return;
            end
            if isempty(obj.d)
                return;
            end
            b = false;
        end
                
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Basic methods to Set/Get native variable
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------
        function SetDataTimeSeries(obj, val)
            obj.d = val;
        end
        
        
        % ---------------------------------------------------------
        function [d, t, ml] = GetDataTimeSeries(obj, options, ~)
            d = obj.d;
            t = obj.t;
            ml = obj.GetMeasurementList(options);
        end        
        
            
        % ---------------------------------------------------------
        function ml = GetMeasurementList(obj, matrixMode, ~)
            if ~exist('matrixMode','var')
                matrixMode = '';
            end
            if strcmpi(matrixMode, 'matrix')
                ml = obj.SD.MeasList;
            else
                ml = MeasListClass();
                for ii = 1:size(obj.SD.MeasList,1)
                    ml(ii).sourceIndex = obj.SD.MeasList(ii,1);
                    ml(ii).detectorIndex = obj.SD.MeasList(ii,2);
                    ml(ii).dataTypeIndex = 0;
                    ml(ii).wavelengthIndex = obj.SD.MeasList(ii,4);
            end
            end
        end
        
                
                
        % ---------------------------------------------------------
        function SetTime(obj, val)
            obj.t = val;
        end
        
        
        % ---------------------------------------------------------
        function val = GetTime(obj, iBlk)
            val = [];
            if iBlk>1
                return
            end
            val = obj.t;
        end
        
        
        % ---------------------------------------------------------
        function val = GetSD(obj)
            val = obj.SD;
        end
        
        
        % ---------------------------------------------------------
        function SetS(obj, val)
            obj.s = val;
        end
        
        
        % ---------------------------------------------------------
        function val = GetS(obj)
            val = obj.s;
        end
        
        
        % ---------------------------------------------------------
        function SetAux(obj, val)
            obj.aux = val;
        end
        
        
        % ---------------------------------------------------------
        function val = GetAux(obj, options)
            if ~exist('options','var')
                options = 'struct';
            end
            if optionExists(options, 'matrix')
                val = obj.aux;
            else
                structtype = struct('name','', 'dataTimeSeries',[]);
                val = struct(structtype([]));
                for ii = 1:size(obj.aux,2)
                    val(ii).name = num2str(ii);
                    val(ii).time = obj.t;
                    val(ii).dataTimeSeries = obj.aux(:,ii);
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function SetCondNames(obj, val)
            obj.CondNames = val;
        end
        
        
        % ---------------------------------------------------------
        function val = GetCondNames(obj)
            val = obj.CondNames;
        end
        
        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = [];
            
            optpos = [obj.SD.SrcPos; obj.SD.DetPos];
            % optpos = [obj.SD.SrcPos; obj.SD.DetPos; obj.SD.DummyPos];
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
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods that must be implemented as a child class of AcqDataClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------
        function val = GetFormatVersion(obj)
            val = obj.formatVersion;
        end
        
        % ---------------------------------------------------------
        function val = GetFormatVersionString(obj)
            val = sprintf('NIRS v%s', obj.GetFormatVersion());
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSDG(obj, ~)
            SD = obj.SD;
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, ~)
            ml = obj.SD.MeasList;
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.SD.Lambda;
        end
        
        
        % ---------------------------------------------------------
        function SetStims_MatInput(obj, s, ~, ~)
            obj.s = s;
        end
        
        
        % ---------------------------------------------------------
        function s = GetStims(obj, t)
            s = obj.s;
        end
        
        
        % ---------------------------------------------------------
        function s = GetStim(obj)
            s = obj.s;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            snew = zeros(size(obj.s,1), length(CondNames));
            for ii=1:length(CondNames)
                k = find(strcmp(obj.CondNames, CondNames{ii}));
                if ~isempty(k)
                    snew(:,ii) = obj.s(:,k);
                end
            end
            obj.CondNames = CondNames;
            obj.s = snew;
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.CondNames;
        end
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj, options) %#ok<*INUSD>
            if ~exist('options','var')
                options = '';
            end
            if optionExists(options,'2D')
                if ~isempty(obj.SD.SrcPos)
            srcpos = obj.SD.SrcPos;
                else
                    srcpos = obj.SD.SrcPos3D;
                end
            else
                if ~isempty(obj.SD.SrcPos3D)
                    srcpos = obj.SD.SrcPos3D;
                else
                    srcpos = obj.SD.SrcPos;
                end
            end
        end
        
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj, options)
            if ~exist('options','var')
                options = '';
            end
            if optionExists(options,'2D')
                if ~isempty(obj.SD.DetPos)
                    detpos = obj.SD.DetPos;
                else
                    detpos = obj.SD.DetPos3D;
                end
            else
                if ~isempty(obj.SD.DetPos3D)
                    detpos = obj.SD.DetPos3D;
                else
                    detpos = obj.SD.DetPos;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = struct('names',{{}}, 'data', obj.aux);
            for ii=1:size(obj.aux, 2)
                if isproperty(obj.SD,'auxChannels')
                    aux.names{end+1} = obj.SD.auxChannels{ii};
                else
                    aux.names{end+1} = sprintf('Aux%d',ii);
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(~)
            n = 1;
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, ich] = GetDataBlocksIdxs(~, ich)
            iDataBlks = 1;
            ich={ich};
        end
        
        
        % ---------------------------------------------------------
        function t = GetAuxiliaryTime(obj)
            t = [];
            if isempty(obj.aux)
                return;
            end
            t = obj.t;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public interface for older processing stream
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function d = Get_d(obj)
            d = obj.d;
        end
        
        % ----------------------------------------------------------------------------------
        function t = Get_t(obj)
            t = obj.t;
        end
        
        % ----------------------------------------------------------------------------------
        function SD = Get_SD(obj)
            SD = [];
            if ~obj.IsProbeValid()
                return;
            end
            SD = obj.SD;
        end
        
        % ----------------------------------------------------------------------------------
        function aux = Get_aux(obj)
            aux = obj.aux;
        end
        
        % ----------------------------------------------------------------------------------
        function s = Get_s(obj)
            s = obj.s;
        end
        
        % ----------------------------------------------------------------------------------
        function CondNames = Get_CondNames(obj)
            CondNames = obj.CondNames;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for stims & conditions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            k = find(strcmp(obj.CondNames, condition));
            if isempty(k)
                obj.s(:,end+1) = zeros(length(obj.t),1);
                icol = size(obj.s,2);
                obj.CondNames{icol} = condition;
            else
                icol = k;
            end
            [~, tidx] = nearest_point(obj.t, tPts);
            obj.s(tidx, icol) = 1;
            obj.SortStims();
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || isempty(condition)
                j = 1:size(obj.s,2);
            else
                j = find(strcmp(obj.CondNames, condition));
            end
            if isempty(j)
                return;
            end
            
            % Find all stims for any conditions which match the time points.
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.t-tPts(ii)) < obj.errmargin )];
            end
            obj.s(k,j) = 0;
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || isempty(condition)
                return;
            end
            
            j = find(strcmp(obj.CondNames, condition));
            if isempty(j)
                % Destination condition wasn't found in data, so add new condition
                j = size(obj.s,2)+1;
                obj.s(:,j) = zeros(1,length(obj.t));
                obj.CondNames{j} = condition;
                obj.SortStims();
                
                % Recalculate j after sort
                j = find(strcmp(obj.CondNames, condition));
            end
            
            % Find all stims for any conditions which match the time points.
            for ii=1:length(tPts)
                % Find index k in the time vector obj.t of time point tPts(ii)
                k = find( abs(obj.t-tPts(ii)) < obj.errmargin );
                
                % Find all columns is obj.s that are non-zero
                i = find(obj.s(k,:)~=0);
                if isempty(i)
                    continue;
                end
                if i(1)==j
                    continue;
                end
                
                % Move the first non-zero column stim to the destination
                % condition
                obj.s(k,j) = obj.s(k,i(1));
                obj.s(k,i(1)) = 0;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimTpts(~, ~, ~)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(~, ~)
            tpts = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(~, ~, ~)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(~, ~)
            duration = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimAmplitudes(~, ~, ~)
            return;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimAmplitudes(obj, icond)
            vals = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            k = find(strcmp(obj.CondNames, oldname));
            if isempty(k)
                return;
            end
            obj.CondNames{k} = newname;
            obj.SortStims();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            nbytes = nbytes + sizeof(obj.t);
            nbytes = nbytes + sizeof(obj.d);
            nbytes = nbytes + sizeof(obj.SD);
            nbytes = nbytes + sizeof(obj.s);
            nbytes = nbytes + sizeof(obj.aux);
            nbytes = nbytes + sizeof(obj.CondNames);
        end

        
        
        % ----------------------------------------------------------------------------------
        function landmarks = InitLandmarks(obj)
            landmarks = struct('pos',[], 'labels',{{}});
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function SD = InitProbe(obj, srcpos, detpos, ml, lambda, dummypos)
            if nargin<2
                srcpos = [];
            end
            if nargin<3
                detpos = [];
            end
            if nargin<4
                ml = [];
            end
            if nargin<5
                lambda = [];
            end
            if nargin<6
                dummypos = [];
            end
            SD = struct(...
                'Lambda',lambda, ...
                'SrcPos',srcpos, ...
                'DetPos',detpos, ...
                'DummyPos',dummypos, ...
                'SrcPos3D',[], ...
                'DetPos3D',[], ...
                'DummyPos3D',[], ...
                'nSrcs',0,...
                'nDets',0,...
                'nDummys',0,...
                'SrcGrommetType',{{}}, ...
                'DetGrommetType',{{}}, ...
                'DummyGrommetType',{{}}, ...
                'SrcGrommetRot',{{}}, ...
                'DetGrommetRot',{{}}, ...
                'DummyGrommetRot',{{}}, ...
                'Landmarks',obj.InitLandmarks(), ...
                'Landmarks2D',obj.InitLandmarks(), ...
                'Landmarks3D',obj.InitLandmarks(), ...
                'MeasList',ml, ...
                'MeasListAct',[], ...
                'SpringList',[], ...
                'AnchorList',{{}}, ...
                'SrcMap',[], ...
                'SpatialUnit','', ...
                'xmin',0, ...
                'xmax',0, ...
                'ymin',0, ...
                'ymax',0, ...
                'auxChannels',{{}} ...
                );
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function SetProbeSpatialUnit(obj, spatialUnitNew, scaling, ndims)
            if ~exist('ndims','var')
                ndims = '2d';
            end
            
            % Set scaling based on current units and desired units if they do not match AND
            % scaling was not explcitly specified (i.e., passed in as an argument). 
            if ~exist('scaling','var') || isempty(scaling)
                scaling = 1;
                if strcmpi(spatialUnitNew,'mm')
                    if strcmpi(obj.SD.SpatialUnit,'cm')
                        scaling = 10;
                    elseif strcmpi(obj.SD.SpatialUnit,'m')
                        scaling = 1000;
                    end
                elseif strcmpi(spatialUnitNew,'cm')
                    if strcmpi(obj.SD.SpatialUnit,'mm')
                        scaling = 1/10;
                    elseif strcmpi(obj.SD.SpatialUnit,'m')
                        scaling = 100;
                    end
                elseif strcmpi(spatialUnitNew,'m')
                    if strcmpi(obj.SD.SpatialUnit,'mm')
                        scaling = 1/1000;
                    elseif strcmpi(obj.SD.SpatialUnit,'cm')
                        scaling = 1/100;
                    end
                else
                    spatialUnitNew = '';
                end
            end 
            
            
            obj.SD.SpatialUnit = spatialUnitNew;
            
            if isempty(ndims) || strcmpi(ndims, '2D')
                obj.SD.SrcPos = obj.SD.SrcPos * scaling;
                obj.SD.DetPos = obj.SD.DetPos * scaling;
                obj.SD.DummyPos = obj.SD.DummyPos * scaling;
                if size(obj.SD.SpringList,2)==3
                    lst = find(obj.SD.SpringList(:,3)~=-1);
                    obj.SD.SpringList(lst,3) = obj.SD.SpringList(lst,3) * scaling;
                end
                obj.SD.Landmarks.pos = obj.SD.Landmarks.pos * scaling;
            end
            
            if isempty(ndims) || strcmpi(ndims, '3D')
                obj.SD.SrcPos3D = obj.SD.SrcPos3D * scaling;
                obj.SD.DetPos3D = obj.SD.DetPos3D * scaling;
                obj.SD.DummyPos3D = obj.SD.DummyPos3D * scaling;
                obj.SD.Landmarks3D.pos = obj.SD.Landmarks3D.pos * scaling;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function FixProbeSpatialUnit(obj)        
            if isempty(obj.SD.SpatialUnit)
                q = MenuBox('Spatial units not provided in probe data. Please specify spatial units of the optode coordinates?', ...
                    {'mm','cm','m'});
                if q==1
                    obj.SD.SpatialUnit = 'mm';
                elseif q==2
                    obj.SD.SpatialUnit = 'cm';
                elseif q==3
                    obj.SD.SpatialUnit = 'm';
                end
            end
            % We don't need to force anything on the user since homer and AV do internal conversions to 'mm'
            %
            %             if ~strcmpi(obj.SD.SpatialUnit,'mm')
            %                 q = MenuBox(sprintf('This probe uses ''%s'' units for probe coordinates. We recommend converting to ''mm'' units, to be consistent with Homer. Do you want to convert probe coordinates from %s to mm?', ...
            %                     obj.SD.SpatialUnit), {'YES','NO'}, 'upperleft');
            %                 if q==1
            %                     obj.SetProbeSpatialUnit('mm')
            %                 end
            %             end
            %
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsProbeValid(obj)
            b = false;
            if ~isfield(obj.SD, 'SrcPos')
                return;
            end
            if ~isfield(obj.SD, 'DetPos')
                return;
            end
            if ~isfield(obj.SD, 'MeasList')
                return;
            end
            if ~isfield(obj.SD, 'Lambda')
                return;
            end
            if isempty(obj.SD.SrcPos)
                return;
            end
            if isempty(obj.SD.DetPos)
                return;
            end
            if isempty(obj.SD.MeasList)
                return;
            end
            if isempty(obj.SD.Lambda)
                return;
            end
            b = true;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsValid(obj)
            b = ~obj.IsEmpty();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CopyProbe(obj, SD)             %#ok<INUSD>
            fields = propnames(obj.SD);
            for ii = 1:length(fields)
                if eval( sprintf('isfield(SD, ''%s'')', fields{ii}) )
                    if eval( sprintf('strcmp(class(obj.SD.%s), class(SD.%s))', fields{ii}, fields{ii}) )
                        eval( sprintf('obj.SD.%s = SD.%s;', fields{ii}, fields{ii}) );
                    elseif eval( sprintf('isnumeric(obj.SD.%s)  &&  iscell(SD.%s)', fields{ii}, fields{ii}) )
                        if eval( sprintf('~isempty(SD.%s)', fields{ii}) )
                            for kk = 1:length(eval( sprintf('SD.%s', fields{ii}) ))
                                if eval( sprintf('isnumeric(SD.%s{kk}) && (length(SD.%s{kk})==1)', fields{ii}, fields{ii}) )
                                    eval( sprintf('obj.SD.%s(kk) = SD.%s{kk};', fields{ii}, fields{ii}) );
                                end
                            end
                        end
                    elseif eval( sprintf('isscalar(obj.SD.%s)  &&  isscalar(SD.%s)', fields{ii}, fields{ii}) )
                        eval( sprintf('obj.SD.%s = SD.%s;', fields{ii}, fields{ii}) );
                    end
                end
            end

            % Fill in any fields that don't conform to standard SD data structure 
                        
            % SrcGrommetType
            d1 = size(obj.SD.SrcPos,1) - length(obj.SD.SrcGrommetType);
            if d1 > 0
                obj.SD.SrcGrommetType(end+1:end+d1) = repmat({'none'}, d1, 1);
            end
            
            % SrcGrommetRot
            d2 = size(obj.SD.SrcPos,1) - length(obj.SD.SrcGrommetRot);
            if d2 > 0
                for ii = length(obj.SD.SrcGrommetRot)+1:length(obj.SD.SrcGrommetRot)+d2
                    if iscell(obj.SD.SrcGrommetRot)
                        obj.SD.SrcGrommetRot{ii} = 0;
                    else
                        obj.SD.SrcGrommetRot(ii) = 0;
                    end
                end
            end
            
            % DetGrommetType
            d1 = size(obj.SD.DetPos,1) - length(obj.SD.DetGrommetType);
            if d1 > 0
                obj.SD.DetGrommetType(end+1:end+d1) = repmat({'none'}, d1, 1);
            end
            
            % DetGrommetRot
            d2 = size(obj.SD.DetPos,1) - length(obj.SD.DetGrommetRot);
            if d2 > 0
                for ii = length(obj.SD.DetGrommetRot)+1:length(obj.SD.DetGrommetRot)+d2
                    if iscell(obj.SD.DetGrommetRot)
                        obj.SD.DetGrommetRot{ii} = 0;
                    else
                        obj.SD.DetGrommetRot(ii) = 0;
                    end
                end
            end

            % DummyGrommetType
            d1 = size(obj.SD.DummyPos,1) - length(obj.SD.DummyGrommetType);
            if d1 > 0
                obj.SD.DummyGrommetType(end+1:end+d1) = repmat({'none'}, d1, 1);
            end
            
            % DummyGrommetRot
            d2 = size(obj.SD.DummyPos,1) - length(obj.SD.DummyGrommetRot);
            if d2 > 0
                for ii = length(obj.SD.DummyGrommetRot)+1:length(obj.SD.DummyGrommetRot)+d2
                    if iscell(obj.SD.DummyGrommetRot)
                        obj.SD.DummyGrommetRot{ii} = 0;
                    else
                        obj.SD.DummyGrommetRot(ii) = 0;
                    end
                end
            end 
                                    
            % MesListAct
            if size(obj.SD.MeasListAct,1) < size(obj.SD.MeasList,1)
                d = size(obj.SD.MeasListAct,1) - size(obj.SD.MeasList,1);
                if d < 0
                    obj.SD.MeasListAct(end+1:end+abs(d)) = ones(abs(d),1);
                elseif d>1
                    obj.SD.MeasListAct(end-d:end) = [];
                end
            end
            
            obj.SD.nSrcs = size(obj.SD.SrcPos,1);
            obj.SD.nDets = size(obj.SD.DetPos,1);
            obj.SD.nDummys = size(obj.SD.DummyPos,1);
        end
        
        
        
        
        % -------------------------------------------------------
        function CopyStim(obj, obj2)
            obj.s = obj2.s;
            obj.CondNames = obj2.CondNames;
        end        
        
        
        
        % ----------------------------------------------------------------------------------
        function CopyStruct(obj, s)            
            fields = propnames(obj);
            for ii = 1:length(fields)
                if eval( sprintf('isfield(s, ''%s'')', fields{ii}) )
                    if strcmp(fields{ii}, 'SD')
                        obj.CopyProbe(s.SD);
                    else
                        eval( sprintf('obj.%s = s.%s;', fields{ii}, fields{ii}) );
                    end
                end
            end
        end

        
        
        % ----------------------------------------------------------------------------------
        function ConvertSnirfProbe(obj, snirf)
            obj.SD.Lambda = snirf.probe.wavelengths;
            obj.SD.SrcPos = snirf.probe.sourcePos2D;
            obj.SD.DetPos = snirf.probe.detectorPos2D;
            obj.SD.SrcPos3D = snirf.probe.sourcePos3D;
            obj.SD.DetPos3D = snirf.probe.detectorPos3D;
            obj.SD.MeasList = snirf.GetMeasList();
            obj.SD.SpatialUnit = snirf.GetLengthUnit();
            if length(snirf.probe.landmarkLabels) == size(snirf.probe.landmarkPos3D,1)
                obj.SD.Landmarks3D.labels   = snirf.probe.landmarkLabels;
            	obj.SD.Landmarks3D.pos      = snirf.probe.landmarkPos3D;
            end
            if length(snirf.probe.landmarkLabels) == size(snirf.probe.landmarkPos2D,1)
            	obj.SD.Landmarks2D.labels   = snirf.probe.landmarkLabels;
                obj.SD.Landmarks2D.pos      = snirf.probe.landmarkPos2D;
        	end
            if     ~isempty(obj.SD.Landmarks3D.labels)
                obj.SD.Landmarks.pos        = obj.SD.Landmarks3D.pos;
                obj.SD.Landmarks.labels     = obj.SD.Landmarks3D.labels;
            elseif ~isempty(obj.SD.Landmarks2D.labels)
                obj.SD.Landmarks.pos        = obj.SD.Landmarks2D.pos;
                obj.SD.Landmarks.labels     = obj.SD.Landmarks2D.labels;
            end                
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ConvertSnirfData(obj, snirf)
            obj.d = snirf.data(1).dataTimeSeries;
            obj.t = snirf.data(1).time;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ConvertSnirfStim(obj, snirf)
            obj.s = zeros(length(obj.t), length(snirf.stim));
            for ii = 1:length(snirf.stim)
                if isempty(snirf.stim(ii).data)
                    ik = [];
                else
                    [~,ik] = nearest_point(obj.t, snirf.stim(ii).data(:,1));
                end
                for jj = 1:length(ik)
                    if ik(jj) == 0
                        ik(jj) = 1;
                    end
                    if ik(jj) > length(obj.t)
                        ik(jj) = length(obj.t);
                    end
                    obj.s(ik(jj),ii) = 1;
                end
                obj.CondNames{ii} = snirf.stim(ii).name;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ConvertSnirfAux(obj, snirf)
            obj.aux = zeros(length(obj.t), length(snirf.aux));
            for ii = 1:length(snirf.aux)
                obj.aux(:,ii) = snirf.aux(ii).dataTimeSeries;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ConvertSnirf(obj, snirf)
            obj.ConvertSnirfProbe(snirf);
            if ~isempty(snirf.data)
                obj.d = snirf.data(1).dataTimeSeries;
                obj.t = snirf.data(1).time;
            end
            obj.ConvertSnirfStim(snirf);
            obj.ConvertSnirfAux(snirf);
        end

        
        
        % -----------------------------------------------------------------------
        function [md2d, md3d] = GetChannelsMeanDistance(obj)
            md2d = [];
            md3d = [];            
            ml = obj.SD.MeasList;
            if isempty(ml)
                return
            end
            k = find(ml(:,4)==1);
            ml = ml(k,:);
            d1 = zeros(size(ml,1),1);
            d2 = zeros(size(ml,1),1);
            for ii = 1:size(ml,1)
                if ml(ii,1) <= size(obj.SD.SrcPos,1) && ml(ii,2) <= size(obj.SD.DetPos,1)
                    d1(ii) = dist3(obj.SD.SrcPos(ml(ii,1),:), obj.SD.DetPos(ml(ii,2),:));
                end
                if ml(ii,1) <= size(obj.SD.SrcPos3D,1) && ml(ii,2) <= size(obj.SD.DetPos3D,1)
                    d2(ii) = dist3(obj.SD.SrcPos3D(ml(ii,1),:), obj.SD.DetPos3D(ml(ii,2),:));
                end
            end
            md2d = mean(d1);
            md3d = mean(d2);
        end
        
        
                        
        % -----------------------------------------------------------------------
        function ErrorCheck(obj)
            if isempty(obj)
                return
            end
            if isempty(obj.SD.SrcGrommetType)
                for ii = 1:size(obj.SD.SrcPos,1)
                    obj.SD.SrcGrommetType{ii} = 'none';
                end
            end
            if isempty(obj.SD.DetGrommetType)
                for ii = 1:size(obj.SD.DetPos,1)
                    obj.SD.DetGrommetType{ii} = 'none';
                end
            end
            if isempty(obj.SD.DummyGrommetType)
                for ii = 1:size(obj.SD.DummyPos,1)
                    obj.SD.DummyGrommetType{ii} = 'none';
                end
            end
            if isempty(obj.SD.SrcGrommetRot)
                for ii = 1:size(obj.SD.SrcPos,1)
                    obj.SD.SrcGrommetRot{ii} = 0;
                end
            end
            if isempty(obj.SD.DetGrommetRot)
                for ii = 1:size(obj.SD.DetPos,1)
                    obj.SD.DetGrommetRot{ii} = 0;
                end
            end
            if isempty(obj.SD.DummyGrommetRot)
                for ii = 1:size(obj.SD.DummyPos,1)
                    obj.SD.DummyGrommetRot{ii} = 0;
                end
            end
            if isempty(obj.CondNames)
                for ii = 1:size(obj.s,2)
                    if length(obj.s(:,ii)) == length(obj.t)
                        obj.CondNames{ii} = num2str(ii);
                    end
                end
            end
            
        end
        
        
        
        % ----------------------------------------------------------------
        function [str, fields] = Properties2String(obj)
            str = '';
            fields = propnames(obj);
            for ii = 1:length(fields)
                if isempty(str)
                    str = sprintf('''%s''', fields{ii});
                else
                    str = sprintf('%s, ''%s''', str, fields{ii});
                end
            end
        end
        
        
        
        % -------------------------------------------------------
        function changes = StimChangesMade(obj)                        
            % Load stims from file
            nirs = NirsClass();
            nirs.SetFilename(obj.GetFilename())
            nirs.LoadStim(obj.GetFilename());
            changes = ~obj.EqualStim(nirs);
        end
        
        
        
        % -------------------------------------------------------
        function b = DataModified(obj)
            b = obj.StimChangesMade();
        end
                
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
    end  % Private methods
    
end

