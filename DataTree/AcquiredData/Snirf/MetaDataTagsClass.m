classdef MetaDataTagsClass  < FileLoadSaveClass

    properties
        tags
    end

    methods
        
        % -------------------------------------------------------
        function obj = MetaDataTagsClass(varargin)
            obj.tags.SubjectID = 'default';
            obj.tags.MeasurementDate = datestr(now,29);
            obj.tags.MeasurementTime = datestr(now,'hh:mm:ss');
            obj.tags.LengthUnit = 'mm';
            obj.tags.TimeUnit = 'unknown';
            
            % Set class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';            
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
                parent = '/nirs/metaDataTags';
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
                info = h5info(fname, parent);
                tags = info.Datasets;
                for ii=1:length(tags)
                    value = convertH5StrToStr(h5read_safe(fname, [parent, '/', tags(ii).Name], []));
                    
                    % Read tag value
                    eval(sprintf('obj.tags.%s = value;', tags(ii).Name));
                    
                end
            catch
                err = -1;
            end
            obj.err = err;
            
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            % Arg 1
            if ~exist('fname', 'var') || isempty(fname)
                error('Unable to save file. No file name given.')
            end
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            props = propnames(obj.tags);
            for ii=1:length(props)
                eval(sprintf('hdf5write_safe(fname, [parent, ''/%s''], obj.tags.%s)', props{ii}, props{ii}));
            end
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
        function Add(obj, key, value)
            key(key==' ') = '';
            eval(sprintf('obj.tags.%s = value', key));
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function tags = Get(obj)
            fields = propnames(obj.tags);
            tags = repmat(struct('key','','value',[]),length(fields),1);
            for ii=1:length(fields)
                eval(sprintf('tags(ii).key = ''%s'';', fields{ii}));
                eval(sprintf('tags(ii).value = obj.tags.%s;', fields{ii}));
            end
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

