classdef MetaDataTagsClass  < FileLoadSaveClass

    properties
        name
        value
    end

    methods
        
        % -------------------------------------------------------
        function obj = MetaDataTagsClass()
            obj.name = '';
            obj.value = '';
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

            % Read tag name
            obj.name = convertH5StrToStr(h5read_safe(fname, [parent, '/name'], obj.name));
            
            % Read tag value
            obj.value = convertH5StrToStr(h5read_safe(fname, [parent, '/value'], obj.value));

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
        

    end
    
end