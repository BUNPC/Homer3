classdef AuxClass < FileLoadSaveClass
    
    properties
        name
        d
        t
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = AuxClass(varargin)
            
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
            
            % Set base class properties not part of the SNIRF format
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
                parent = '/snirf/aux_1';
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
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            
            hdf5write(fname, [parent, '/name'], obj.name, 'WriteMode','append');
            hdf5write_safe(fname, [parent, '/d'], obj.d);
            hdf5write_safe(fname, [parent, '/t'], obj.t);
        end
        
        
        % -------------------------------------------------------
        function d = GetData(obj)
            d = obj.d;
        end
        
    end
    
end