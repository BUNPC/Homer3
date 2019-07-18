classdef AuxClass < FileLoadSaveClass
    
    properties
        name
        dataTimeSeries
        time
        timeOffset
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = AuxClass(varargin)
            
            obj.timeOffset = 0;
            if nargin==1
                obj.filename = varargin{1};
                obj.Load();
            elseif nargin==3
                obj.dataTimeSeries    = varargin{1};
                obj.time = varargin{2};
                obj.name = varargin{3};
            else
                obj.name = '';
                obj.dataTimeSeries = [];
                obj.time = [];
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
                parent = '/nirs/aux1';
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
                nm = convertH5StrToStr(h5read(fname, [parent, '/name']));
                if iscell(nm)
                    obj.name = nm{1};
                else
                    obj.name = nm;
                end
                obj.dataTimeSeries    = h5read(fname, [parent, '/dataTimeSeries']);
                obj.time    = h5read(fname, [parent, '/time']);
                obj.timeOffset    = h5read(fname, [parent, '/timeOffset']);
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
            hdf5write_safe(fname, [parent, '/dataTimeSeries'], obj.dataTimeSeries);
            hdf5write_safe(fname, [parent, '/time'], obj.time);
            hdf5write_safe(fname, [parent, '/timeOffset'], obj.timeOffset);
        end
        
        
        % -------------------------------------------------------
        function d = GetData(obj)
            d = obj.dataTimeSeries;
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            if ~all(obj.dataTimeSeries(:)==obj2.dataTimeSeries(:))
                return;
            end
            if ~all(obj.time(:)==obj2.time(:))
                return;
            end
            if obj.timeOffset(:)~=obj2.timeOffset
                return;
            end
            B = true;
        end
        
    end
    
end

