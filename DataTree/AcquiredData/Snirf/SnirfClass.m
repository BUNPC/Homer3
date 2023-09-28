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
        fid
        gid
        location
        nirsdatanum
        nirs_tb
        stim0
        hFig
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = SnirfClass(varargin)
            %
            % Syntax:
            %   obj = SnirfClass()
            %   obj = SnirfClass(filename);
            %   obj = SnirfClass(filename, nirsdatanum);
            %   obj = SnirfClass(filename, nirsdatanum, dataStorageScheme);
            %   obj = SnirfClass(filename, dataStorageScheme);
            %   obj = SnirfClass(dotnirs);
            %   obj = SnirfClass(dotnirs, numdatabllocks);
            %   obj = SnirfClass(data, stim);
            %   obj = SnirfClass(data, stim, probe);
            %   obj = SnirfClass(data, stim, probe, aux);
            %   obj = SnirfClass(d, t, SD, aux, s);
            %   obj = SnirfClass(d, t, SD, aux, s, CondNames);
            %
            %   Also for debugging/simulation of time bases
            %
            %   obj = SnirfClass(dotnirs, tfactors);
            %
            % Example 1:
            %
            %   % Save .nirs file in SNIRF format
            %   snirf1 = SnirfClass(load('neuro_run01.nirs','-mat'));
            %   snirf1.Save('neuro_run01.snirf');
            %   snirf1.Info()
            %
            %   % Check that the file was saved correctly
            %   snirf2 = SnirfClass();
            %   snirf2.Load('neuro_run01.snirf');
            %   snirf2.Info()
            %
            % Example 2:
            %
            %   Nirs2Snirf('Simple_Probe1.nirs');
            %   obj = SnirfClass('Simple_Probe1.snirf');
            %
            %   Here's some of the output:
            %
            %   obj(1).data ====>
            %
            %       DataClass with properties:
            %
            %           data: [1200x8 double]
            %           time: [1200x1 double]
            %           measurementList: [1x8 MeasListClass]
            %
            
            obj = obj@AcqDataClass(varargin);
            
            % Initialize properties from SNIRF spec
            obj.Initialize()
            
            % Set class properties NOT part of the SNIRF format
            obj.SetFileFormat('hdf5');
            obj.location = '/nirs';
            obj.nirsdatanum = 1;
            obj.hFig = [-1; -1];

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Between 1 and 4 arguments covers the following syntax variants
            %
            % obj = SnirfClass(filename);
            % obj = SnirfClass(filename, nirsdatanum);
            % obj = SnirfClass(filename, nirsdatanum, dataStorageScheme);
            % obj = SnirfClass(filename, dataStorageScheme);
            % obj = SnirfClass(dotnirs);
            % obj = SnirfClass(dotnirs, numdatabllocks);
            % obj = SnirfClass(SD);
            % obj = SnirfClass(data, stim);
            % obj = SnirfClass(data, stim, probe);
            % obj = SnirfClass(data, stim, probe, aux);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin>0 && nargin<5
                
                % obj = SnirfClass(filename);
                if isa(varargin{1}, 'SnirfClass')
                    obj.Copy(varargin{1});
                    return;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % obj = SnirfClass(filename, nirsdatanum);
                % obj = SnirfClass(filename, nirsdatanum, dataStorageScheme);
                % obj = SnirfClass(filename, dataStorageScheme);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ischar(varargin{1})
                    obj.SetFilename(varargin{1});
                    if nargin>1
                        % obj = SnirfClass(filename, nirsdatanum);
                        if isnumeric(varargin{2})
                            obj.nirsdatanum = varargin{2};
                            
                            % obj = SnirfClass(filename, nirsdatanum, dataStorageScheme);
                            if nargin>2
                                obj.dataStorageScheme = varargin{3};
                            end
                            
                            % obj = SnirfClass(filename, dataStorageScheme);
                        elseif ischar(varargin{2})
                            obj.SetDataStorageScheme(varargin{2});
                            
                        end
                    end
                    
                    % Load Snirf file here ONLY if data storage scheme is 'memory'
                    if strcmpi(obj.GetDataStorageScheme, 'memory')
                        obj.Load(varargin{1});
                    end
                    
                    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % obj = SnirfClass(dotnirs);
                % obj = SnirfClass(dotnirs, numdatabllocks);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif NirsClass(varargin{1}).IsValid()
                    
                    % obj = SnirfClass(dotnirs);
                    tfactors = 1;    % Debug simulation parameter
                    
                    % obj = SnirfClass(dotnirs, numdatabllocks);
                    if nargin==2
                        tfactors = varargin{2};
                    end
                    dotnirs = NirsClass(varargin{1});
                    obj.GenSimulatedTimeBases(dotnirs, tfactors);
                    
                    % Required fields
                    for ii = 1:length(tfactors)
                        obj.data(ii) = DataClass(obj.nirs_tb(ii).d, obj.nirs_tb(ii).t(:), obj.nirs_tb(ii).SD.MeasList);
                    end
                    obj.probe       = ProbeClass(dotnirs.SD);                    
                    obj.metaDataTags.SetLengthUnit(dotnirs.SD.SpatialUnit);
                    
                    % Optional fields
                    if isproperty(dotnirs,'s')
                        for ii = 1:size(dotnirs.s,2)
                            if isproperty(dotnirs, 'CondNames')
                                obj.stim(ii) = StimClass(dotnirs.s(:,ii), dotnirs.t(:), dotnirs.CondNames{ii});
                            else
                                obj.stim(ii) = StimClass(dotnirs.s(:,ii), dotnirs.t(:), num2str(ii));
                            end
                        end
                    end
                    if isproperty(dotnirs,'aux')
                        for ii = 1:size(dotnirs.aux,2)
                            obj.aux(ii) = AuxClass(dotnirs.aux(:,ii), dotnirs.t(:), sprintf('aux%d',ii));
                        end
                    end
                    
                    % Add required field metadatatags that has no .nirs
                    % equivalent 
                    obj.metaDataTags   = MetaDataTagsClass('', dotnirs.SD.SpatialUnit);
                    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % obj = SnirfClass(SD);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif NirsClass(varargin{1}).IsProbeValid()
                    
                    n = NirsClass(varargin{1});
                    obj.probe = ProbeClass(n.SD);
                    obj.data = DataClass(n.SD);                    
                    obj.metaDataTags   = MetaDataTagsClass('', n.SD.SpatialUnit);
                                        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % obj = SnirfClass(data, stim);
                % obj = SnirfClass(data, stim, probe);
                % obj = SnirfClass(data, stim, probe, aux);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif isa(varargin{1}, 'DataClass')
                    
                    % obj = SnirfClass(data, stim);
                    data = varargin{1};
                    obj.SetData(data);
                    stim = varargin{2};
                    obj.SetStim(stim);
                    
                    % obj = SnirfClass(data, stim, probe);
                    if nargin>2
                        probe = varargin{3};
                        obj.SetSd(probe);
                    end
                    
                    % obj = SnirfClass(data, stim, probe, aux);
                    if nargin>3
                        aux = varargin{4};
                        obj.SetAux(aux);
                    end
                    
                end
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Between 5 and 6 arguments covers the following syntax variants
            %
            % obj = SnirfClass(d, t, SD, aux, s);
            % obj = SnirfClass(d, t, SD, aux, s, CondNames);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif nargin>4
                
                % obj = SnirfClass(d, t, SD, aux, s);
                d         = varargin{1};
                t         = varargin{2}(:);
                SD        = varargin{3};
                aux       = varargin{4};
                s         = varargin{5};
                CondNames = {};
                
                % obj = SnirfClass(d, t, SD, aux, s, CondNames);
                if nargin>5
                    CondNames = varargin{6};
                end
                
                obj.data(1) = DataClass(d, t(:), SD.MeasList);
                for ii = 1:size(s,2)
                    if nargin==5
                        condition = num2str(ii);
                    else
                        condition = CondNames{ii};
                    end
                    obj.stim(ii) = StimClass(s(:,ii), t(:), condition);
                end
                obj.probe      = ProbeClass(SD);
                for ii = 1:size(aux,2)
                    obj.aux(ii) = AuxClass(aux, t(:), sprintf('aux%d',ii));
                end
                
                % Add metadatatags
                obj.metaDataTags   = MetaDataTagsClass();
                
            end
            
        end
        
        
        
        % -------------------------------------------------------
        function Initialize(obj)
            Initialize@AcqDataClass(obj)
            
            obj.formatVersion = '1.0';
            obj.metaDataTags   = MetaDataTagsClass().empty();
            obj.data           = DataClass().empty();
            obj.stim           = StimClass().empty();
            obj.probe          = ProbeClass().empty();
            obj.aux            = AuxClass().empty();
            
            % Initialize non-SNIRF variables
            obj.stim0          = StimClass().empty();            
            obj.errmsgs = {
                'MATLAB could not load the file.'
                '''formatVersion'' is invalid.'
                '''metaDataTags'' field is invalid.'
                '''data'' field is invalid.'
                '''stim'' field has corrupt data. Some or all stims could not be loaded'
                '''probe'' field is invalid.'
                '''aux'' field is invalid and could not be loaded'
                'WARNING: ''data'' field corrupt and unusable'
                };
        end
        
               
        
        % -------------------------------------------------------
        function err = Copy(obj, obj2)
            err=0;
            if ~isa(obj2, 'SnirfClass')
                err=1;
                return;
            end
            if obj.Mismatch(obj2)
                return;
            end
            obj.formatVersion = obj2.formatVersion;
            obj.metaDataTags  = CopyHandles(obj2.metaDataTags);
            obj.data          = CopyHandles(obj2.data);
            obj.stim          = CopyHandles(obj2.stim);
            obj.probe         = CopyHandles(obj2.probe);
            obj.aux           = CopyHandles(obj2.aux);
            
            try
                obj.stim0     = CopyHandles(obj2.stim0);
            catch
            end
            
            if ~isempty(obj2.GetFilename()) && isempty(obj.GetFilename())
                obj.SetFilename(obj2.GetFilename());
            end
            obj.SetDataStorageScheme(obj2.GetDataStorageScheme());
        end
        
        
        
        % -------------------------------------------------------
        function objnew = CopyMutable(obj, options)
            if nargin==1
                options = '';
            end
            
            % Load mutable data from Snirf file here ONLY if data storage scheme is 'files'
            if strcmpi(obj.GetDataStorageScheme(), 'files')
                obj.LoadStim(obj.GetFilename());
            end
            
            % Generate new instance of SnirfClass
            objnew = SnirfClass();
            
            objnew.SetFilename(obj.GetFilename);
            
            % Copy mutable properties to new object instance;
            objnew.stim = CopyHandles(obj.stim);
            objnew.SortStims();
            objnew.SetDataStorageScheme(obj.GetDataStorageScheme());            
        end
        
        
        
        % -------------------------------------------------------
        function ReloadStim(obj, obj2)            
            if strcmpi(obj2.GetDataStorageScheme(), 'files')
                obj2.LoadStim(obj2.GetFilename());
            end
            obj.stim = CopyHandles(obj2.stim);
            obj.SortStims();
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
        function err = SetLocation(obj)
            err = 0;
            gid1 = HDF5_GroupOpen(obj.fid, sprintf('%s%d', obj.location, obj.nirsdatanum));
            gid2 = HDF5_GroupOpen(obj.fid, obj.location);
            
            if gid1.double > 0
                obj.location = sprintf('%s%d', obj.location, obj.nirsdatanum);
                return;
            elseif gid2.double > 0
                return;
            end
            err = -1;
        end
        
        
        
        
        % -------------------------------------------------------
        function err = LoadFormatVersion(obj)
            err = 0;
            formatVersionFile = HDF5_DatasetLoad(obj.gid, 'formatVersion'); %#ok<*PROPLC>
            formatVersionFile = str2double(formatVersionFile);
            formatVersionCurr = str2double(obj.formatVersion);
            if formatVersionFile < formatVersionCurr
                obj.logger.Write(sprintf('Warning: Current SNIRF version is %0.1f. Cannot load older version (%0.1f) file. Backward compatibility not yet implemented ...\n', ...
                    formatVersionCurr, formatVersionFile));
                err = -2;
                return
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadMetaDataTags(obj, fileobj)
            err = 0;
            obj.metaDataTags = MetaDataTagsClass();
            if obj.metaDataTags.LoadHdf5(fileobj, [obj.location, '/metaDataTags']) < 0
                err = -1;
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadTime(obj)
            err = 0;
            if isempty(obj.data)
                obj.data = DataClass();
                err = obj.data.LoadTime(obj.GetFilename(), [obj.location, '/data1']);
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadData(obj, fileobj)
            err = 0;
            ii=1;
            while 1
                if ii > length(obj.data)
                    obj.data(ii) = DataClass;
                end
                
                err = obj.data(ii).LoadHdf5(fileobj, [obj.location, '/data', num2str(ii)]);
                if err < 0
                    obj.data(ii).delete();
                    obj.data(ii) = [];
                    if err == -1
                        err = 0;
                    end
                    break;
                elseif err > 0
                    break
                end
                ii=ii+1;
            end
            
            % This is a required field. If it's empty means the whole snirf object is bad
            if isempty(obj.data)
                err = -1;
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadStim(obj, fileobj)
            err = 0;
            
            if obj.LoadStimOverride(obj.GetFilename())
%                 if obj.GetError()<0
%                     err = -1;
%                 end
                return
            end
            
            obj.stim  = StimClass().empty();
            
            ii=1;
            while 1
                if ii > length(obj.stim)
                    obj.stim(ii) = StimClass;
                end
                err = obj.stim(ii).LoadHdf5(fileobj, [obj.location, '/stim', num2str(ii)]);
                if err ~= 0
                    obj.stim(ii).delete();
                    obj.stim(ii) = [];
                    break;
                else
                    for kk = 1:ii-1
                        if strcmp(obj.stim(kk).name, obj.stim(ii).name)
                            obj.stim(ii).delete();
                            obj.stim(ii) = [];
                            err = err-6;
                            break
                        end
                    end
                    if err ~= 0
                        break;
                    end
                end
                ii=ii+1;
            end
            
            % Load original, unedited stims, if they exist
            ii=1;
            while 1
                if ii > length(obj.stim0)
                    obj.stim0(ii) = StimClass;
                end
                if obj.stim0(ii).LoadHdf5(fileobj, [obj.location, '/stim0', num2str(ii)]) ~= 0
                    obj.stim0(ii).delete();
                    obj.stim0(ii) = [];
                    break;
                end
                ii=ii+1;
            end
            
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadProbe(obj, fileobj, ~)
            % metaDataTags is a prerequisite for load probe, so check to make sure its already been loaded
            if isempty(obj.metaDataTags)
                obj.LoadMetaDataTags(fileobj);
            end
                
            % get lenth unit through class method
            LengthUnit = obj.metaDataTags.Get('LengthUnit');
            obj.probe = ProbeClass();
            err = obj.probe.LoadHdf5(fileobj, [obj.location, '/probe'], LengthUnit);
            
            % This is a required field. If it's empty means the whole snirf object is bad
            if isempty(obj.probe)
                err = -1;
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadAux(obj, fileobj)
            err = 0;
            ii=1;
            while 1
                if ii > length(obj.aux)
                    obj.aux(ii) = AuxClass;
                end
                err = obj.aux(ii).LoadHdf5(fileobj, [obj.location, '/aux', num2str(ii)]);
                if err ~= 0
                    obj.aux(ii).delete();
                    obj.aux(ii) = [];
                    break;
                end
                ii=ii+1;
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, ~)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj','var') || ~exist(fileobj,'file')
                fileobj = '';
            end
            
            % Error checking
            if ~isempty(fileobj) && ischar(fileobj)
                obj.SetFilename(fileobj);
            elseif isempty(fileobj)
                fileobj = obj.GetFilename();
            end
            if isempty(fileobj)
                err = -1;
                return;
            end
            
            % Don't reload if not empty
            if ~obj.IsEmpty()
                obj.LoadStim(fileobj);
                err = obj.GetError();     % preserve error state if exiting early
                return;
            end
            
            
            %%%%%%%%%%%% Ready to load from file
            
            try
                
                % Open group
                [obj.gid, obj.fid] = HDF5_GroupOpen(fileobj, '/');
                
                
                if obj.SetLocation() < 0 && err == 0
                    err = -1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % NOTE: Optional fields have positive error codes if they are
                % missing, but negative error codes if they're not missing but 
                % invalid
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%% Load formatVersion
                if obj.LoadFormatVersion() < 0 && err >= 0
                    err = -2;
                end

                %%%% Load metaDataTags
                if obj.LoadMetaDataTags(obj.fid) < 0 && err >= 0
                    % Here a positive return value means that invalid data meta tags 
                    % should NOT be a show stopper if we can help it, if the reste of the data 
                    % is valid. So just let user know they're invalid with a warning.
                    err = 3;
                end

                %%%% Load data
                errtmp = obj.LoadData(obj.fid);
                if errtmp < 0 && err >= 0
                    err = -4;
                elseif errtmp == 5 && err >= 0
                	err = 8;
                elseif errtmp > 0 && err >= 0
                    err = 4;
                end

                %%%% Load stim
                if obj.LoadStim(obj.fid) < 0 && err >= 0
                    % Optional field: even if invalid we still want to be
                    % able to work with the rest of the data. Only log
                    % warning
                    err = 5;
                end

                %%%% Load probe
                if obj.LoadProbe(obj.fid) < 0 && err >= 0
                    err = -6;
                end

                %%%% Load aux. This is an optional field
                if obj.LoadAux(obj.fid) < 0 && err >= 0
                    % Optional field: even if invalid we still want to be
                    % able to work with the rest of the data. Only log
                    % warning
                    err = 7;
                end
                
                % Close group
                HDF5_GroupClose(fileobj, obj.gid, obj.fid);
                
            catch
                
                err = -1;
                
            end
            
            if obj.fid > 0
                H5F.close(obj.fid);
            end
            
        end
        
        
        % -------------------------------------------------------
        function SaveMetaDataTags(obj, fileobj)
            if ~isempty(obj.metaDataTags)
                obj.metaDataTags.SaveHdf5(fileobj, [obj.location, '/metaDataTags']);
            end
        end
        
        
        
        % -------------------------------------------------------
        function SaveData(obj, fileobj)
            for ii = 1:length(obj.data)
                obj.data(ii).SaveHdf5(fileobj, [obj.location, '/data', num2str(ii)]);
            end
        end
        
        
        % -------------------------------------------------------
        function SaveStim(obj, fileobj)
            for ii = 1:length(obj.stim)
                obj.stim(ii).SaveHdf5(fileobj, [obj.location, '/stim', num2str(ii)]);
            end
            if isempty(obj.stim0)
                obj.stim0 = obj.stim.copy();
                for ii = 1:length(obj.stim0)
                    obj.stim0(ii).SaveHdf5(fileobj, [obj.location, '/stim0', num2str(ii)]);
                end
            end
        end
        
        
        % -------------------------------------------------------
        function SaveProbe(obj, fileobj)
            if ~isempty(obj.probe)
                obj.probe.SaveHdf5(fileobj, [obj.location, '/probe']);
            end
        end
        
        
        % -------------------------------------------------------
        function SaveAux(obj, fileobj)
            for ii = 1:length(obj.aux)
                obj.aux(ii).SaveHdf5(fileobj, [obj.location, '/aux', num2str(ii)]);
            end
        end
        
        
        
        % -------------------------------------------------------
        function err = SaveHdf5(obj, fileobj, ~)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj','var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Args
            if exist(fileobj, 'file')
                delete(fileobj);
            end

            % Convert file object to HDF5 file descriptor
            obj.fid = HDF5_GetFileDescriptor(fileobj);
            if obj.fid < 0
                err = -1;
                return;
            end
            
            %%%%% Save this object's properties
            try
                
                % Save formatVersion
                if isempty(obj.formatVersion)
                    obj.formatVersion = '1.1';
                end
                hdf5write_safe(obj.fid, '/formatVersion', obj.formatVersion);
                
                % Save metaDataTags
                obj.SaveMetaDataTags(obj.fid);
                
                % Save data
                obj.SaveData(obj.fid);
                
                % Save stim
                obj.SaveStim(obj.fid);
                
                % Save sd
                obj.SaveProbe(obj.fid);
                
                % Save aux
                obj.SaveAux(obj.fid);
                
            catch ME
                
                H5F.close(obj.fid);
                if ispathvalid(fileobj)
                    delete(fileobj);
                end
                rethrow(ME)
                
            end
            
            H5F.close(obj.fid);
        end
        
        
        
        % -------------------------------------------------------
        function [stimFromFile, changes] = UpdateStim(obj, fileobj)
            flags = zeros(length(obj.stim), 1);
            
            % Load stim from file and update it
            snirfFile = SnirfClass(fileobj);
            
            % Update stims from file with edited stims
            for ii = 1:length(obj.stim)
                for jj = 1:length(snirfFile.stim)
                    if strcmp(obj.stim(ii).GetName(), snirfFile.stim(jj).GetName())
                        if obj.stim(ii) ~= snirfFile.stim(jj)
                            snirfFile.stim(jj).Copy(obj.stim(ii));
                        end
                        flags(ii) = 1;
                        break;
                    end
                end
                if ~flags(ii)
                    % We have new stimulus condition added
                    if ~obj.stim(ii).IsEmpty()
                        snirfFile.stim(end+1) = StimClass(obj.stim(ii));
                        flags(ii) = 1;
                    end
                end
            end
            
            % If stims were edited then update snirf file with new stims
            changes = sum(flags);
            if changes > 0
                snirfFile.Save();
            end
            stimFromFile = snirfFile.stim;
        end
        
        
        
        % -------------------------------------------------------
        function CopyStim(obj, obj2)
            obj.stim = StimClass.empty();
            for ii = 1:length(obj2.stim)
                obj.stim(ii) = StimClass(obj2.stim(ii));
            end
        end        
        
        
        % -------------------------------------------------------
        function changes = StimChangesMade(obj)                        
            % Load stims from file
            snirf = SnirfClass();
            snirf.SetFilename(obj.GetFilename())
            snirf.LoadStim(obj.GetFilename());
            changes = ~obj.EqualStim(snirf);
        end
        
        
        
        % -------------------------------------------------------
        function b = DataModified(obj)
            b = obj.StimChangesMade();
        end
        
        
        
        % -------------------------------------------------------
        function err = SaveMutable(obj, fileobj)
            if isempty(obj)
                return
            end
            
            % Arg 1
            if ~exist('fileobj','var') || ~exist(fileobj,'file')
                fileobj = '';
            end
            
            % Error checking
            if ~isempty(fileobj) && ischar(fileobj)
                obj.SetFilename(fileobj);
            elseif isempty(fileobj)
                fileobj = obj.GetFilename();
            end
            if isempty(fileobj)
                err = -1;
                return;
            end
            
            % Update original stims and save back to file
            obj.UpdateStim(fileobj);
        end
        
        
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~strcmp(obj.formatVersion, obj2.formatVersion)
                return;
            end
            if ~obj.EqualData(obj2)
                return;
            end
            if ~obj.EqualStim(obj2)
                return;
            end
            if obj.probe ~= obj2.probe
                return;
            end
            if ~obj.EqualAux(obj2)
                return;
            end
            B = true;
        end
        
        
        
        % --------------------------------------------------------------------
        function b = EqualMetaDataTags(obj, obj2)
            b = false;
            if length(obj.metaDataTags) ~= length(obj2.metaDataTags)
                return;
            end
            for ii = 1:length(obj.metaDataTags)
                if obj.metaDataTags(ii) ~= obj2.metaDataTags(ii)
                    return;
                end
            end
            b = true;
        end
        
        
        
        % --------------------------------------------------------------------
        function b = EqualData(obj, obj2)
            b = false;
            if length(obj.data) ~= length(obj2.data)
                return;
            end
            for ii = 1:length(obj.data)
                if obj.data(ii) ~= obj2.data(ii)
                    return;
                end
            end
            b = true;
        end
        
        
        
        % --------------------------------------------------------------------
        function b = EqualStim(obj, obj2)
            b = false;
            for ii = 1:length(obj.stim)
                flag = false;
                for jj = 1:length(obj2.stim)
                    if obj.stim(ii) == obj2.stim(jj)
                        flag = true;
                        break;
                    end
                end
                if flag==false
                    % If obj condition was NOT found in obj2 BUT it is empty (no data), then we don't 
                    % count that as a unequal criteria, that is, obj and obj2 are still considered equal
                    if ~obj.stim(ii).IsEmpty()
                        return;
                    end
                end
            end
            for ii = 1:length(obj2.stim)
                flag = false;
                for jj = 1:length(obj.stim)
                    if obj2.stim(ii) == obj.stim(jj)
                        flag = true;
                        break;
                    end
                end
                if flag==false
                    % If obj2 condition was NOT found in obj BUT it is empty (no data), then we don't 
                    % count that as a unequal criteria, that is, obj and obj2 are still considered equal
                    if ~obj2.stim(ii).IsEmpty()
                        return;
                    end
                end
            end
            b = true;
        end
        
        
        
        % --------------------------------------------------------------------
        function b = EqualAux(obj, obj2)
            b = false;
            for ii = 1:length(obj.aux)
                flag = false;
                for jj = 1:length(obj2.aux)
                    if obj.aux(ii) == obj2.aux(jj)
                        flag = true;
                        break;
                    end
                end
                if flag==false
                    return;
                end
            end
            for ii = 1:length(obj2.aux)
                flag = false;
                for jj = 1:length(obj.aux)
                    if obj2.aux(ii) == obj.aux(jj)
                        flag = true;
                        break;
                    end
                end
                if flag==false
                    return;
                end
            end
            b = true;
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
        function [val, t] = GetData(obj, iBlk)
            val = [];
            t = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if isempty(obj) || isempty(obj.data)
                return;
            end
            val = obj.data(iBlk);
            t = obj.data(iBlk).time;
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
            if isempty(obj)
                return;
            end
            if isempty(obj.metaDataTags)
                return;
            end
            val = obj.metaDataTags.Get();
        end
        
        % ---------------------------------------------------------
        function val = GetLengthUnit(obj)
            val = [];
            if isempty(obj)
                return;
            end
            if isempty(obj.metaDataTags)
                return;
            end
            val = obj.metaDataTags.Get('LengthUnit');
        end
        
        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.probe.GetSdgBbox();
        end                
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods that must be implemented as a child class of AcqDataClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------
        function t = GetTime(obj, iBlk)
            t = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            if iBlk>length(obj.data)
                return;
            end
            t = obj.data(iBlk).GetTime();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasurementList(obj, matrixMode, iBlk)
            ml = [];
            if ~exist('matrixMode','var')
                matrixMode = '';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            freememory = false;
            if isempty(obj.data)
                obj.LoadData(obj.GetFilename());
                freememory = true;
            end
            if iBlk>length(obj.data)
                return;
            end
            ml = obj.data(iBlk).GetMeasurementList(matrixMode);
            if freememory 
                obj.FreeMemory(obj.GetFilename());
            end
        end
        
        
        
        % ---------------------------------------------------------
        function [d, t, ml] = GetDataTimeSeries(obj, options, iBlk)
            d = [];
            t = [];
            ml = [];
            if ~exist('options','var')
                options = '';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            if iBlk>length(obj.data)
                return;
            end
            [d, t, ml] = obj.data(iBlk).GetDataTimeSeries(options);
        end
        
        
        
        % ---------------------------------------------------------
        function [datamat, p, Nmin] = GetAuxDataMatrix(obj, obj2)            
            datamat = [];
            p = 0;
            Nmin = 0;
            
            if isempty(obj.aux)
                return;
            end
            if ~exist('obj2','var')
                obj2 = obj.data(1);            
            end
            
            datamat = zeros(size(obj2.dataTimeSeries,1), length(obj.aux));
            
            % Get all aux channels to be on the same time base with obj2 which by default is the data
            for ii = 1:length(obj.aux)
                if length(obj2.GetTime()) < length(obj.aux(ii).GetTime())   % dessimate
                    p = length(obj2.GetTime());
                    q = length(obj.aux(ii).GetTime());
                elseif length(obj2.GetTime()) > length(obj.aux(ii).GetTime())  % interpolate
                    p = length(obj.aux(ii).GetTime());
                    q = length(obj2.GetTime());
                else
                    p = length(obj2.GetTime());
                    q = length(obj.aux(ii).GetTime());
                end
                datamat(:,ii) = resample(obj.aux(ii).GetDataTimeSeries(), p, q);
            end
        end
        
        
        
        % ---------------------------------------------------------
        function names = GetAuxNames(obj)
            names = {};
            for ii=1:length(obj.aux)
                names{ii} = obj.aux(ii).GetName();
            end
        end
        
        
        % ---------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = struct('names',{{}}, 'data', obj.aux);
            aux.names = obj.GetAuxNames();
            aux.data = obj.GetAuxDataMatrix();
        end
        
        
        % ---------------------------------------------------------
        function t = GetAuxiliaryTime(obj)
            t = [];
            if isempty(obj.aux)
                return;
            end
            if obj.aux(1).IsEmpty()
                return;
            end
            t = obj.aux(1).GetTime();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, iBlk)
            ml = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            if iBlk>length(obj.data)
                return;
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
                        obj.stim(ii).EditState(t(tidxs(jj)), s(tidxs(jj),ii));
                    end
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function s = GetStims(obj, t)
            % Returns a .nirs style stim signal. Stim state marks are
            % interpolated onto the time series t from their respective
            % onset times.
            s = zeros(length(t), length(obj.stim));
            for i=1:length(obj.stim)
                states = obj.stim(i).GetStates();
                if ~isempty(states)
                    [~, k] = nearest_point(t, states(:, 1));
                    if ~isempty(k)
                        s(k,i) = states(:, 2);
                    end
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function s = GetStimAmps(obj, t)
            % Returns a .nirs style stim signal. Stim amplitudes are
            % interpolated onto the time series t from their respective
            % onset times.
            s = zeros(length(t), length(obj.stim));
            for ii=1:length(obj.stim)
                data = obj.stim.GetData();
                if ~isempty(data)
                    [~, k] = nearest_point(t, data(:, 1));
                    if isempty(k)
                        continue;
                    end
                    s(k,ii) = data(:, 3);
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            
            % Bug fix: unique with no arguments changes the order by
            % sorting. Here order should be preserved or else we have problems. 
            % Add the 'stable' argument to preseerve order. JD, Nov 1, 2022
            CondNamesLocal = unique({obj.stim.name}, 'stable');
            stimnew = StimClass().empty;
            for ii=1:length(CondNames)
                k = find(strcmp(CondNamesLocal, CondNames{ii}));
                if ~isempty(k)
                    stimnew(ii) = StimClass(obj.stim(k));
                else
                    stimnew(ii) = StimClass(CondNames{ii});
                end
            end
            obj.stim = stimnew.copy;
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = cell(1,length(obj.stim));
            for ii=1:length(obj.stim)
                CondNames{ii} = obj.stim(ii).GetName();
            end
        end
        
        
        % ---------------------------------------------------------
        function probe = GetProbe(obj)
            obj.LoadProbe(obj.GetFilename());
            probe = obj.probe;
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSDG(obj,option)
            SD = [];
            if isempty(obj)
                return;
            end
            if isempty(obj.probe)
                return;
            end
            SD.Lambda = obj.probe.GetWls();
            if exist('option','var')
                SD.SrcPos = obj.probe.GetSrcPos(option);
                SD.DetPos = obj.probe.GetDetPos(option);
            else
                SD.SrcPos = obj.probe.GetSrcPos();
                SD.DetPos = obj.probe.GetDetPos();
            end
        end
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj, options)
            if exist(options,'var')
                options = '';
            end
            srcpos = obj.probe.GetSrcPos(options);
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj, options)
            if exist(options,'var')
                options = '';
            end
            detpos = obj.probe.GetDetPos(options);
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
        
        
        % ---------------------------------------------------------
        function unit = GetSpatialUnit(obj)
            unit = obj.metaDataTags.Get('LengthUnits');
        end
        
        
        
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pubic interface for .nirs processing stream
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function d = Get_d(obj, iBlk)
            d = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if iBlk>length(obj.data)
                return;
            end
            d = obj.data(iBlk).GetDataTimeSeries();
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = Get_t(obj, iBlk)
            t = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if iBlk>length(obj.data)
                return;
            end
            t = obj.data(iBlk).GetTime();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = Get_SD(obj, iBlk, option)
            SD = [];
            if isempty(obj.probe)
                return;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if iBlk>length(obj.data)
                return;
            end
            SD.Lambda   = obj.probe.GetWls();
            if exist('option','var')
                SD.SrcPos   = obj.probe.GetSrcPos(option);
                SD.DetPos   = obj.probe.GetDetPos(option);
            else
                SD.SrcPos   = obj.probe.GetSrcPos();
                SD.DetPos   = obj.probe.GetDetPos();
            end
            SD.MeasList = obj.data(iBlk).GetMeasList();
            SD.MeasListAct = ones(size(SD.MeasList,1),1);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function s = Get_s(obj, iBlk)
            s = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if iBlk>length(obj.data)
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
        function AddStims(obj, tPts, condition, duration, amp, more)
            % Try to find existing condition to which to add stims.
            for ii=1:length(obj.stim)
                if strcmp(condition, obj.stim(ii).GetName())
                    obj.stim(ii).AddStims(tPts, duration, amp, more);
                    return;
                end
            end
            
            % Otherwise we have a new condition to which to add the stims.
            obj.stim(end+1) = StimClass(condition);
            obj.stim(end).AddStims(tPts, duration, amp, more);
            obj.SortStims();
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, ~)
            % Find all stims for any conditions which match the time points.
            for ii=1:length(obj.stim)
                obj.stim(ii).DeleteStims(tPts);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts, ~)
            % Find all stims for any conditions which match the time points.
            for ii=1:length(obj.stim)
                obj.stim(ii).ToggleStims(tPts);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function AddStimColumn(obj, name, initValue)
            for i=1:length(obj.stim)
                obj.stim(i).AddStimColumn(name, initValue);
            end
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStimColumn(obj, idx)
            for i=1:length(obj.stim)
                obj.stim(i).DeleteStimColumn(idx);
            end
        end
        
        % ----------------------------------------------------------------------------------
        function RenameStimColumn(obj, oldname, newname)
            if ~exist('oldname', 'var') || ~exist('newname', 'var')
                return;
            end
            for i=1:length(obj.stim)
                obj.stim(i).RenameStimColumn(oldname, newname);
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
            idx_dst = [];
            for ii=1:length(obj.stim)
                if strcmp(condition, obj.stim(ii).GetName())
                    idx_dst=ii;
                    break;
                end
            end
            
            % If no destination condition found among existing conditions,
            % then create a new condition to move stims to
            if isempty(idx_dst)
                idx_dst = length(obj.stim)+1;
                
                % Otherwise we have a new condition to which to add the stims.
                obj.stim(idx_dst) = StimClass([], condition);
                obj.SortStims();
                
                % Recalculate j after sort
                for ii=1:length(obj.stim)
                    if strcmp(condition, obj.stim(ii).GetName())
                        idx_dst=ii;
                        break;
                    end
                end
            end
            
            for i=1:length(obj.stim)
                data = obj.stim(i).GetData();
                for j=1:size(data, 1)
                    onset = data(j, 1);
                    if onset > min(tPts) & onset < max(tPts)
                        % Delete the stim from its condition and add it to selected dst
                        duration = data(j, 2);
                        amplitude = data(j, 3);
                        more = data(j, 4:end);
                        obj.stim(i).DeleteStims(onset);
                        obj.stim(idx_dst).AddStims(onset, duration, amplitude, more);
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
        function val = GetStimData(obj, icond)
            val = obj.stim(icond).GetData();
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = GetStimDataLabels(obj, icond)
            val = obj.stim(icond).GetDataLabels();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration, tpts)
            obj.stim(icond).SetDuration(duration, tpts);
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
        function SetStimAmplitudes(obj, icond, amps, tpts)
            obj.stim(icond).SetAmplitudes(amps, tpts);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimAmplitudes(obj, icond)
            if icond>length(obj.stim)
                vals = [];
                return;
            end
            vals = obj.stim(icond).GetAmplitudes();
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
            if isempty(obj.data) || (isa(obj.data, 'DataClass') && obj.data(1).IsEmpty())
                return;
            end
            if isempty(obj.data) || (isa(obj.probe, 'ProbeClass') && obj.probe.IsEmpty())
                return;
            end
            b = false;
        end
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            nbytes = nbytes + sizeof(obj.formatVersion);
            for ii=1:length(obj.metaDataTags)
                nbytes = nbytes + obj.metaDataTags(ii).MemoryRequired();
            end
            for ii=1:length(obj.data)
                nbytes = nbytes + obj.data(ii).MemoryRequired();
            end
            for ii=1:length(obj.stim)
                nbytes = nbytes + obj.stim(ii).MemoryRequired();
            end
            if ~isempty(obj.probe)
                nbytes = nbytes + obj.probe.MemoryRequired();
            end
            for ii=1:length(obj.aux)
                nbytes = nbytes + obj.aux(ii).MemoryRequired();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Info(obj)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Read formatVersion
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('\n');
            fprintf('    FormatVersion:\n');
            fv = obj.GetFormatVersion();
            fprintf('        Format version: %s\n', fv);
            fprintf('\n');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load meta data tags from file and extract the tag names and values for display
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('    MetaDataTags:\n');
            tags = obj.GetMetaDataTags();
            for ii=1:length(tags)
                fprintf('        Tag #%d: {''%s'', ''%s''}\n', ii, tags(ii).key, tags(ii).value);
            end
            fprintf('\n');
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load data from file and extract .nirs-style d and ml matrices for display
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('    Data (.nirs-style display):\n');
            for ii=1:length(obj.data)
                
                % Display data matrix dimensions and data type
                d = obj.data(ii).GetDataTimeSeries();
                pretty_print_struct(d, 8, 1);
                
                % Display meas list dimensions and data type
                ml = obj.data(ii).GetMeasList();
                pretty_print_struct(ml, 8, 1);
                
            end
            fprintf('\n');
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load probe and extract .nirs-style SD structure
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('    Probe (.nirs-style display):\n');
            SD = obj.GetSDG('2D');
            pretty_print_struct(SD, 8, 1);
            fprintf('\n');
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load stim from file and extract it for display
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('    Stim (.snirf-style display):\n');
            for ii=1:length(obj.stim)
                fprintf('        stim(%d): {name = ''%s'', data = [', ii, obj.stim(ii).name);
                for jj=1:size(obj.stim(ii).data,1)
                    if jj==size(obj.stim(ii).data,1)
                        fprintf('%0.1f', obj.stim(ii).data(jj,1));
                    else
                        fprintf('%0.1f, ', obj.stim(ii).data(jj,1));
                    end
                end
                fprintf(']}\n');
            end
            fprintf('\n');
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load aux from file and extract nirs-style data for display
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('    Aux (.nirs-style display):\n');
            auxl = obj.GetAuxiliary();
            pretty_print_struct(auxl, 8, 1);
            fprintf('\n');
            
        end
        
        
        
        % -----------------------------------------------------------------------
        function [md2d, md3d] = GetChannelsMeanDistance(obj)
            ml = obj.data(1).GetMeasListSrcDetPairs();
            d1 = zeros(size(ml,1),1);
            for ii = 1:length(d1)
                d1(ii) = dist3(obj.probe.sourcePos2D(ml(ii,1),:), obj.probe.detectorPos2D(ml(ii,2),:)); 
                d2(ii) = dist3(obj.probe.sourcePos3D(ml(ii,1),:), obj.probe.detectorPos3D(ml(ii,2),:)); 
            end
            md2d = mean(d1);
            md3d = mean(d2);
        end
        
        
        
        % -----------------------------------------------------------------------
        function err = ErrorCheckSpatialUnits(obj)
            err = 0;
            msg = [];
            [md2d, md3d] = obj.GetChannelsMeanDistance();
            LengthUnitDeclared = obj.metaDataTags.GetLengthUnit();            
            magnitudeMm = log10(30);
            magnitudeCm = log10(3);
            magnitudeM  = log10(.03);
            
            % 2D coordinates
            diffMm = abs(magnitudeMm - log10(md2d));
            diffCm = abs(magnitudeCm - log10(md2d));
            diffM = abs(magnitudeM - log10(md2d));
            [~, idx] =  min([diffMm, diffCm, diffM]);
            if idx == 1
                LengthUnitActual2D = 'mm';
            elseif idx == 2
                LengthUnitActual2D = 'cm';
            elseif idx == 3
                LengthUnitActual2D = 'm';
            end
            if ~strcmpi(LengthUnitDeclared, LengthUnitActual2D)
                msg{1} = sprintf('WARNING: Declared LengthUnit (%s) might not match the likely actual units (%s) of the 2D coordinates\n', ...
                    LengthUnitDeclared, LengthUnitActual2D);
            end
            
            % 2D coordinates
            diffMm = abs(magnitudeMm - log10(md3d));
            diffCm = abs(magnitudeCm - log10(md3d));
            diffM = abs(magnitudeM - log10(md3d));
            [~, idx] =  min([diffMm, diffCm, diffM]);
            if idx == 1
                LengthUnitActual3D = 'mm';
            elseif idx == 2
                LengthUnitActual3D = 'cm';
            elseif idx == 3
                LengthUnitActual3D = 'm';
            end
            if ~strcmpi(LengthUnitDeclared, LengthUnitActual3D)
                msg{2} = sprintf('WARNING: Declared LengthUnit (%s) might not match the likely actual units (%s) of the 3D coordinates\n\n', ...
                    LengthUnitDeclared, LengthUnitActual3D);
            end
            
            % Compare 2D units with 3D units
            if ~strcmpi(LengthUnitActual2D, LengthUnitActual3D)
                msg{3} = sprintf('WARNING: The likely actual units of the 2D coordinates (%s) might not match the like actual units of the 3D coordinates (%s)\n\n', ...
                    LengthUnitActual3D, LengthUnitActual3D);
            end
            
            if ~isempty(msg)
                MenuBox(msg);
            end
        end



        % ----------------------------------------------------------------------------------
        function hAxes = GenerateStandaloneAxes(obj, datatype, iChs)
            k = find(obj.hFig(1,:)==-1);
            obj.hFig(1,k(1)) = figure;
            hAxes = gca;
            plotname = sprintf('"%s";   %s data ;   channels idxs: [%s]', obj.GetFilename(),  datatype, num2str(iChs'));
            namesize = uint32(length(plotname)/3);
            set(obj.hFig(1,k(1)), 'units','characters');
            p1 = get(obj.hFig(1,k(1)), 'position');
            set(obj.hFig(1,k(1)), 'name',plotname, 'menubar','none', 'NumberTitle','off', 'position',[p1(1)/2, p1(2), p1(3)+namesize, p1(4)]);
            obj.hFig(:,k(1)+1) = -1;
        end
           
        
            
        % ----------------------------------------------------------------------------------
        function Plot(obj, sdPairs, iBlk)
            %
            % SYNTAX:
            %   TreeNodeClass.Plot(iChs, iBlk)
            % 
            %
            % DESCRIPTION:
            %   Plot data from channels specified by 2d array where each row spoecifying a single channel
            %   contains indices [source, detector, condition, wavelength]. In addtion to the data, this method 
            %   plots any existing stims, and the probe associated with the SNIRF object from which the data 
            %   was taken. NOTE: the args iBlk and hAxes can be ommitted and will default to 1 and current 
            %   axes respectively.
            %
            %
            % INPUT:
            %   sdPairs - 2d array of channel indices where each row represents a channel consisting of the indices
            %             [source, detector, condition, datatype]
            %
            %   iBlk - Optional argument (defaults = 1). In theory SNIRF data field is an array of data blocks. This argunment selects the 
            %          data block from which the plot data is taken.
            %   
            %   hAxes - Optional argument (default is current axes or gca()), specifying the axes handle of the axes in which to plot the data.
            %
            %
            
            % Parse input args
            if ~exist('sdPairs','var')
                sdPairs = [1,1,0,1];
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end

            
            % Convert channels in the form of a list of sd pairs to a column vector of indices into the measurement list
            iChs = obj.SdPairIdxs2vectorIdxs(sdPairs, iBlk);
            
            
            % Extract SNIRF parameters for plotting:  probe, data, time, measuremntList and stim
            d = obj.data(1).dataTimeSeries;
            t = obj.data(1).time;
            ml = obj.data(1).GetMeasurementList('matrix');
            
            % If there's no data to plot then exit
            if isempty(d)
                fprintf('No data to plot\n');
                return;
            end
            
            
            % Set up standalone figure with axes for plotting data, if axes handle was not passed down from caller 
            % in the last arg. There will be a separate figure displaying the probe associated with this data plot. 
            % a few lines down in DisplayProbe.
            hAxes = obj.GenerateStandaloneAxes('HRF', iChs);            
                        
            % Plot data
            hold on
            chSelect = [];
            for ii = 1:length(iChs)
                hdata(ii) = plot(hAxes, t, d(:,iChs(ii)), 'linewidth',2);
                chSelect(ii,:) = [ml(iChs(ii),1), ml(iChs(ii),2), ml(iChs(ii),3), ml(iChs(ii),4), get(hdata(ii), 'color')]; 
            end
            set(hAxes, 'xlim', [t(1), t(end)]);                        
            
            % Display probe in separate figure
            if isempty(chSelect)
                fprintf('ERROR: no valid channels were selelcted\n');
                obj.DisplayProbe();
            else
                obj.DisplayProbe(chSelect(:,1:2), chSelect(:,5:7));
            end
            
            
            % Wrap up before exiting
            drawnow;
            pause(.1);
            hold off
        end
        
        
        % ----------------------------------------------------------------------------------
        function iChs = SdPairIdxs2vectorIdxs(obj, sdPairs, iBlk)
            iChs = [];
            if ~exist('sdPairs','var')
                sdPairs = [1,1,0,1];
            end            
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            % Error Checking
            if size(sdPairs, 2)>1 && size(sdPairs, 2)~=4
                fprintf('ERROR: invalid sdPair. sdPair has to be a Nx4 2D array\n');
                return;
            end
            
            
            % If sdPairs argument is a column vector then we are done because channels are 
            % already specified in the output format i.e., as single number indices. 
            if size(sdPairs, 2)==1
                iChs = sdPairs;
                return;
            end            
                        
            ml = obj.data(1).GetMeasurementList('matrix', iBlk);
            
            % Error checking
            if isempty(ml)
                return
            end
            
            for ii = 1:size(sdPairs,1)
                k = find(ml(:,1)==sdPairs(ii,1)  &  ml(:,2)==sdPairs(ii,2)  &  ml(:,3)==sdPairs(ii,3)  &  ml(:,4)==sdPairs(ii,4));
                if isempty(k)
                    continue;
                end
                iChs(ii,1) = k;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function sdPairs = VectorIdxs2SdPairIdxs(obj, iChs, iBlk)
            if ~exist('iChs','var')
                iChs = 1;
            end            
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            % If sdPairs argument is not a column vector then we are done;  because the 
            % channels are already specified in the output format i.e., as a 2d array. 
            if size(iChs, 2)>1
                sdPairs = iChs;
                return;
            end
            
            ml = obj.data(1).GetMeasurementList('matrix', iBlk);
            
            % Remove any invalid indices
            iChs(iChs==0) = [];
            iChs(iChs>size(ml,1)) = [];
            
            sdPairs = ml(iChs,:);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function hAxes = DisplayProbe(obj, chSelect, chSelectColors, hAxes)
            % Parse args
            if ~exist('chSelect','var')
                chSelect = [];
            end
            if ~exist('chSelectColors','var')                
                chSelectColors = repmat([1.0, 0.5, 0.2], size(chSelect,1),1);
            end
            if ~exist('hAxes','var')
                hAxes = [];
            end
            
            % If chSelect is in the form of a column vector rather than sd pairs
            % then convert to sd pairs
            chSelect = obj.VectorIdxs2SdPairIdxs(chSelect);            
            
            freememoryflag = false;
            if ~isempty(obj) && obj.IsEmpty()
                obj.acquired.Load();
                freememoryflag = true;
            end
            
            % Set up the axes
            bbox = obj.GetSdgBbox();
            if isempty(hAxes)
                k = find(obj.hFig(2,:)==-1);
                
                % See if there's a data plot associated with this probe display
                % If there is get its name and use it to name this figure
                plotname = '';
                if ishandle(obj.hFig(1,k(1)))
                    plotname = get(obj.hFig(1,k(1)), 'name');
                end
                obj.hFig(2,k(1)) = figure('menubar','none', 'NumberTitle','off', 'name',plotname);
                hAxes = gca;
            end

            axis(hAxes, [bbox(1), bbox(2), bbox(3), bbox(4)]);
            gridsize = get(hAxes, {'xlim', 'ylim', 'zlim'});
            if ismac() || islinux()
                fs = 18;
            else
                fs = 11;
            end

            % Get probe paramaters
            probe = obj.GetProbe();
            srcpos = probe.sourcePos2D;
            detpos = probe.detectorPos2D;
            ml = obj.GetMeasurementList('matrix');
            lstSDPairs = find(ml(:,4)==1);
            
            % Draw all channels
            for ii = 1:length(lstSDPairs)
                hCh(ii) = line2(srcpos(ml(lstSDPairs(ii),1),:), detpos(ml(lstSDPairs(ii),2),:), [], gridsize, hAxes);
                col = [1.00 1.00 1.00] * 0.85;
                if ~isempty(chSelect)
                    k = find(chSelect(:,1)==ml(lstSDPairs(ii),1) & chSelect(:,2)==ml(lstSDPairs(ii),2));
                    if ~isempty(k)
                        col = chSelectColors(k(1),:);
                    end
                end
                set(hCh(ii), 'color',col, 'linewidth',2, 'linestyle','-', 'userdata',ml(lstSDPairs(ii),1:2));
            end
            
            % ADD SOURCE AND DETECTOR LABELS
            for iSrc = 1:size(srcpos,1)
                if ~isempty(find(ml(:,1)==iSrc)) %#ok<*EFIND>
                    hSD(iSrc) = text( srcpos(iSrc,1), srcpos(iSrc,2), sprintf('%d', iSrc), 'fontsize',fs, 'fontweight','bold', 'color','r' );
                    set(hSD(iSrc), 'horizontalalignment','center', 'edgecolor','none', 'Clipping', 'on');
                end
            end
            for iDet = 1:size(detpos,1)
                if ~isempty(find(ml(:,2)==iDet))
                    hSD(iDet+iSrc) = text( detpos(iDet,1), detpos(iDet,2), sprintf('%d', iDet), 'fontsize',fs, 'fontweight','bold', 'color','b' );
                    set(hSD(iDet+iSrc), 'horizontalalignment','center', 'edgecolor','none', 'Clipping', 'on');
                end
            end
            
            if freememoryflag
                obj.FreeMemory();
            end            
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


