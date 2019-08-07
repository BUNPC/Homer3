classdef MetaDataTagsClass  < FileLoadSaveClass

    properties
        name
        value
    end

    methods
        
        % -------------------------------------------------------
        function obj = MetaDataTagsClass(varargin)
            obj.name = '';
            obj.value = '';
            
            % Set class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';
            
            % Set SNIRF fomat properties
            if nargin==0
                return;
	        end
            if nargin==1
                obj.name = varargin{1};
                obj.value = 'none';
                return;
            end            
            obj.name = varargin{1};
            obj.value = varargin{2};            
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
                parent = '/nirs/metaDataTags1';
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
            % Read tag name
            obj.name = convertH5StrToStr(h5read_safe(fname, [parent, '/name'], obj.name));
            if isempty(obj.name)
               err=-1;
            end
            
            % Read tag value
            obj.value = convertH5StrToStr(h5read_safe(fname, [parent, '/value'], obj.value));
            catch
                err = -1;
            end
            obj.err = err;
            
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fname, [parent, '/name'], obj.name);
            hdf5write_safe(fname, [parent, '/value'], obj.value);
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            if ~strcmp(obj.value, obj2.value)
                return;
            end
            B = true;
        end
        
        
        
        % -------------------------------------------------------
        function Add(obj, name, value)
            obj.name = name;
            obj.value = value;
        end
        
    end
    
end