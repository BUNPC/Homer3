classdef AuxClass < FileLoadSaveClass
    
    properties
        name
        dataTimeSeries
        time
        timeOffset
    end

    % Properties not part of the SNIRF spec. These parameters aren't loaded or saved to files
    properties (Access = private)
        debuglevel
    end    

    methods
        
        % -------------------------------------------------------
        function obj = AuxClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');

            obj.debuglevel = DebugLevel('none');
            
            obj.timeOffset = 0;
            if nargin==1
                if isa(varargin{1}, 'AuxClass')
                    obj = varargin{1}.copy();
                elseif ischar(varargin{1})
                    obj.SetFilename(varargin{1});
                    obj.Load();
                end
            elseif nargin==3
                obj.dataTimeSeries    = varargin{1};
                obj.time = varargin{2};
                obj.name = varargin{3};
            else
                obj.name = '';
                obj.dataTimeSeries = [];
                obj.time = [];
            end                        
        end
        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, location)
            
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~exist(fileobj,'file'))
                fileobj = '';
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/aux1';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            % Error checking for file existence
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
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);
                
                % Absence of optional aux field raises error > 0
                if gid.double < 0
                    err = 1;
                    return;
                end
                
                obj.name            = HDF5_DatasetLoad(gid, 'name');
                obj.dataTimeSeries  = HDF5_DatasetLoad(gid, 'dataTimeSeries');
                obj.time            = HDF5_DatasetLoad(gid, 'time');
                obj.timeOffset      = HDF5_DatasetLoad(gid, 'timeOffset');
               
                % Name should not be loaded as a 1x1 cell array, but some
                % Python interfaces lead to it being saved this way.
                %
                % This is due to the string being saved in fixed vs.
                % variable length format. See: https://support.hdfgroup.org/HDF5/doc1.6/UG/11_Datatypes.html
                %
                % As of version 1.0 of the SNIRF specification, this is not
                % an issue of spec compliance.
                if iscell(obj.name) && length(obj.name) == 1
                    obj.name = obj.name{1};
                end
                
                err = obj.ErrorCheck();
                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
                
            catch
                
                if gid.double > 0
                    % If optional aux field exists BUT is in some way invalid it raises error < 0
                    err = -6;
                else
                    err = 1;
                end
                
            end
        end

        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location)
            % Arg 1
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/aux1';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            
            if obj.debuglevel.Get() == obj.debuglevel.SimulateBadData()
                obj.SimulateBadData();
            end
            
            hdf5write_safe(fileobj, [location, '/name'], obj.name);
            hdf5write_safe(fileobj, [location, '/dataTimeSeries'], obj.dataTimeSeries);
            hdf5write_safe(fileobj, [location, '/time'], obj.time);
            hdf5write_safe(fileobj, [location, '/timeOffset'], obj.timeOffset);
        end
        
        
        % ---------------------------------------------------------
        function SetDataTimeSeries(obj, val)
            if ~exist('val','var')
                return;
            end
            obj.dataTimeSeries = val;
        end
        
        
        % -------------------------------------------------------
        function d = GetDataTimeSeries(obj)
            d = obj.dataTimeSeries;
        end
        
        
        % -------------------------------------------------------
        function name = GetName(obj)
            name = obj.name;
        end
        
        
        % -------------------------------------------------------
        function val = GetTime(obj)
            val = obj.time;
        end
        
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isempty(obj)
                obj = DataClass();
            end
            if ~isa(obj2, 'DataClass')
                return;
            end
            for ii=1:length(obj2.measurementList)
                obj.measurementList(ii) = obj2.measurementList(ii).copy();      % shallow copy ok because MeasListClass has no handle properties
            end
            obj.dataTimeSeries = obj2.dataTimeSeries;
            obj.time = obj2.time;
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
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return
            end
            nbytes = sizeof(obj.name) + sizeof(obj.dataTimeSeries) + sizeof(obj.time) + sizeof(obj.timeOffset);
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return
            end
            if isempty(obj.name)
                return
            end
            if isempty(obj.dataTimeSeries)
                return
            end
            if isempty(obj.time)
                return
            end
            if length(obj.dataTimeSeries) ~= length(obj.time)
                return
            end
            b = false;
        end
        
        
        % ----------------------------------------------------------------------------------
        function err = ErrorCheck(obj)
            err = 0;
            if isempty(obj.name)
                err = -1;
                return
            end
            if isempty(obj.dataTimeSeries)
                err = -2;
                return
            end
            if isempty(obj.time)
                err = -3;
                return
            end
            if length(obj.dataTimeSeries) ~= length(obj.time)
                err = -4;
                return
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SimulateBadData(obj)
            obj.dataTimeSeries(end,:) = [];
        end
        
    end
    
end

