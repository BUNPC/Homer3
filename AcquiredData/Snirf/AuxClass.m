classdef AuxClass  < matlab.mixin.Copyable
    
    properties
        filename
        name
        d
        t
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = AuxClass(varargin)
            obj.filename = '';
            
            if nargin==1
                obj.filename = varargin{1};
                obj.Load();
            elseif nargin==3
                obj.d    = varargin{1};
                obj.t    = varargin{2};
                obj.name = varargin{3};
            else
                obj.name = '';
                obj.d = [];
                obj.t = [];
            end
            
        end
        
        
        % -------------------------------------------------------
        function err = Load(obj, fname, parent)

            err = 0;
            
            % Overwrite 1st argument if the property filename is NOT empty
            if ~isempty(obj.filename)
                fname = obj.filename;
            end
            
            % Arg 1
            if ~exist('fname','var')
                err = -1;
                return;
            end
            if ~exist(fname,'file')
                err = -1;
                return;
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/snirf/aux_1';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end

            try
                name = strtrim(h5read(fname, [parent, '/name']));
                obj.name = name{1};
                obj.d    = h5read(fname, [parent, '/d']);
                obj.t    = h5read(fname, [parent, '/t']);
            catch
                err = -1;
                return;
            end

        end

        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            
            hdf5write(fname, [parent, '/name'], obj.name, 'WriteMode','append');
            hdf5write_safe(fname, [parent, '/d'], obj.d);
            hdf5write_safe(fname, [parent, '/t'], obj.t);

        end
        
    end
    
end