classdef MetaDataTagsClass  < FileLoadSaveClass

    properties
        tags
    end

    methods
        
        % -------------------------------------------------------
        function obj = MetaDataTagsClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');

            obj.tags.SubjectID = 'default';
            obj.tags.MeasurementDate = datestr(now,29);
            obj.tags.MeasurementTime = datestr(now,'hh:mm:ss');
            obj.tags.LengthUnit = 'mm';
            obj.tags.TimeUnit = 'unknown';
            obj.tags.FrequencyUnit = 'unknown';
            obj.tags.AppName  = 'snirf-homer3';
            
            if nargin==1 && ~isempty(varargin{1})
                obj.SetFilename(varargin{1});
                obj.Load();
            end
            if nargin==2
                obj.tags.LengthUnit = varargin{2};
            end
        end
    
        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, location)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~exist(fileobj,'file'))
                fileobj = '';
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/metaDataTags';
            elseif location(1)~='/'
                location = ['/',location];
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
            
            
            %%%%%%%%%%%% Ready to load from file

            try
                % Reset tags
                obj.tags = struct();
                
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);
                
                metaDataStruct = h5loadgroup(gid);
                tags = fieldnames(metaDataStruct); %#ok<*PROPLC>
                for ii=1:length(tags)
                    eval(sprintf('obj.tags.%s = metaDataStruct.%s;', tags{ii}, tags{ii}));
                end
                
                HDF5_GroupClose(fileobj, gid, fid);

                % Detect old or invalid metadatatag data
                assert(obj.IsValid());
                
            catch
                
                err = -1;
                
            end
            
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location) %#ok<*INUSD>
            % Arg 1
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/metaDataTags';
            elseif location(1)~='/'
                location = ['/',location]; %#ok<*NASGU>
            end
            
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            props = propnames(obj.tags);
            for ii=1:length(props)
                eval(sprintf('hdf5write_safe(fileobj, [location, ''/%s''], obj.tags.%s);', props{ii}, props{ii}));
            end
        end
        
        
        
        % -------------------------------------------------------
        function b = IsValid(obj)
            b = false;
            
            % Use latest required fields to determine if we're loading old
            % metaDataTag format version of SNIRF spec
            if ~isproperty(obj.tags, 'FrequencyUnit')
                return;
            end
            
            b = true;
        end

        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            props1 = propnames(obj.tags);
            props2 = propnames(obj2.tags);
            for ii=1:length(props1)
                if ~isproperty(obj2.tags, props1{ii})
                    return;
                end
                if eval(sprintf('~strcmp(obj.tags.%s, obj2.tags.%s)', props1{ii}, props1{ii}))
                    return;
                end
            end
            for ii=1:length(props2)
                if ~isproperty(obj.tags, props2{ii})
                    return;
                end
                if eval(sprintf('~strcmp(obj.tags.%s, obj2.tags.%s)', props2{ii}, props2{ii}))
                    return;
                end
            end
            B = true;
        end
        
        
        
        % -------------------------------------------------------
        function Add(obj, key, value) %#ok<INUSL>
            key(key==' ') = '';
            eval(sprintf('obj.tags.%s = value', key));
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function val = Get(obj, name)
            val = [];
            if ~exist('name', 'var')
                return;
            end
            if isfield(obj.tags, name)
                val = eval( sprintf('obj.tags.%s;', name) );
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Set(obj, name, val) %#ok<INUSL>
            eval(sprintf('obj.tags.%s = %s;', name, val));
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetLengthUnit(obj, unit)
            if isempty(obj)
                return
            end
            obj.tags.LengthUnit = unit;
        end
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            fields = propnames(obj.tags);
            for ii=1:length(fields)
                nbytes = nbytes + eval(sprintf('sizeof(obj.tags.%s)', fields{ii}));
            end
        end
        
    end    
end

