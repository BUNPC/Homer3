classdef StimClass < FileLoadSaveClass
    
    properties
        name
        data
        states  % Stim marks enabled/disabled. Not part of SNIRF
    end
   
    properties (Access = private)
        errmargin  % Margin for interpolating onset times. Not part of SNIRF
    end    
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');
            obj.errmargin = 1e-3;
            obj.states = [];
            if nargin==1 
                if isa(varargin{1}, 'StimClass')
                    obj.Copy(varargin{1});
                elseif ischar(varargin{1})
                    if exist(varargin{1}, 'file')==2
                        obj.SetFilename(varargin{1});
                        obj.Load(varargin{1});
                    else
                        obj.name = varargin{1};
                        obj.data = [];
                    end
                end
            elseif nargin==2
                if ischar(varargin{1})
                    obj.SetFilename(varargin{1});
                    obj.Load(varargin{1}, obj.fileformat, varargin{2});
                else
                    t        = varargin{1};
                    CondName = varargin{2};
                    obj.name = CondName;
                    for ii=1:length(t)
                        obj.data(end+1,:) = [t(ii), 10, 1];
                        obj.states(end+1,:) = [t(ii), 1];
                    end
                end
            elseif nargin==3
                s        = varargin{1};
                t        = varargin{2};
                CondName = varargin{3};
                obj.name = CondName;
                k = s>0 | s==-1 | s==-2;  % Include stim marks with these values
                obj.data = [t(k), 5*ones(length(t(k)),1), ones(length(t(k)),1)];
            elseif nargin==0
                obj.name = '';
                obj.data = [];
            end
            obj.updateStates();
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
                location = '/nirs/stim1';
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
               
            try 
                
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);
                
                % Load datasets
                obj.name   = HDF5_DatasetLoad(gid, 'name');
                obj.data   = HDF5_DatasetLoad(gid, 'data', [], '2D');                
                if all(obj.data(:)==0)
                    obj.data = [];
                end
                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
                
            catch ME
                
                err = -1;
                return
                
            end
            obj.updateStates();
        end
        
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location)
            if isempty(obj.data)
                obj.data = 0;
            end
            
            % Arg 1
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/stim1';
            elseif location(1)~='/'
                location = ['/',location];
            end

            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write_safe(fileobj, [location, '/name'], obj.name);
            
            % Since this is a writable writeable parameter AFTER it's creation, we 
            % call hdf5write_safe with the 'rw' option
            hdf5write_safe(fileobj, [location, '/data'], obj.data, 'rw:2D');
            hdf5write_safe(fileobj, [location, '/dataLabels'], obj.dataLabels, 'rw');
        end
        
                
        % -------------------------------------------------------
        function Update(obj, fileobj, location)
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fileobj, [location, '/name'], obj.name);
            hdf5write_safe(fileobj, [location, '/data'], obj.data, 'w');
        end
        
        
        % -------------------------------------------------------
        function Copy(obj, obj2)
            obj.name = obj2.name;
            obj.data = obj2.data;
            obj.states = obj2.states;
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            
            % Dimensions matter so dimensions must equal
            if ~all(size(obj.data)==size(obj2.data))
                return;
            end
            
            % Now check contents
            if ~all(obj.data(:)==obj2.data(:))
                return;
            end
            B = true;
        end
    
        function updateStates(obj)
            % Generate a state list compatible with the data array
            if isempty(obj.data)
                return;
            end
            if isempty(obj.states)
                obj.states = ones(size(obj.data, 1), 2);
                for i=1:size(obj.data, 1)
                    obj.states(i, 1) = obj.data(i,1);
                end
            else
                for i=1:size(obj.states, 1)
                    if isempty(find(abs(obj.data(:,1) - obj.states(i,1)) <  obj.errmargin ))
                        % If there is a state val for a nonexistant stim,
                        % remove it
                        obj.states(i,:) = [];
                    end
                end
                for i=1:size(obj.data, 1)
                   if isempty(find(abs(obj.states(:,1) - obj.data(i,1)) <  obj.errmargin ))
                       % If there is no state val for a data row, add one
                       obj.states(end+1,:) = [obj.data(i,1), 1]; 
                   end
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
               
        % -------------------------------------------------------
        function SetName(obj, val)
            obj.name = val;
        end
        
        % -------------------------------------------------------
        function val = GetName(obj)
            val = obj.name;
        end
               
        % -------------------------------------------------------
        function SetData(obj, val)
            obj.data = val;
        end
        
        % -------------------------------------------------------
        function val = GetData(obj)
            val = obj.data;
        end

        % -------------------------------------------------------
        function SetStates(obj, states)
            obj.states = states;
        end
        
        % -------------------------------------------------------
        function val = GetStates(obj)
            val = obj.states;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All other public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function b = Exists(obj, tPt)
            b = false;
            if ~exist('tPt','var')
                return;
            end
            if isempty(obj.data)
                return;
            end
            if isempty(find( abs(obj.data(:,1)-tPt) <  obj.errmargin ))
                return;
            end
            b = true;
        end

        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, duration, amp)
            if ~exist('duration','var')
                duration = 10;
            end
            if ~exist('amp','var')
                amp = 1;
            end
            for ii=1:length(tPts)
                if ~obj.Exists(tPts(ii))
                    obj.data(end+1,:) = [tPts(ii), duration, amp];
                    obj.states(end+1,:) = [tPts(ii), 1];
                end
            end
        end

        
        % ----------------------------------------------------------------------------------
        function EditAmplitude(obj, tPts, amp)
            if isempty(obj.data)
                return;
            end
            if ~exist('amp','var')
                amp = 1;
            end
            for ii=1:length(tPts)
                k = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
                obj.data(k,3) = amp;
            end
        end

        
        % ----------------------------------------------------------------------------------
        function EditState(obj, tPts, state)
            if isempty(obj.data)
                return;
            end
            if ~exist('state','var')
                state = 1;
            end
            for ii=1:length(tPts)
                k = find( abs(obj.states(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
                obj.states(k,2) = state;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetTpts(obj, tPts, k)
            if ~exist('k','var')
                k = 1:size(obj.data,1);
            end
            if ~exist('tPts','var')
                return;
            end
            if length(tPts)~=1 && length(tPts)~=length(k)
                return;
            end
            obj.data(k,1) = tPts;
        end

        
        % -------------------------------------------------------
        function tPts = GetTpts(obj, k)
            tPts = [];
            if isempty(obj.data)
                return;
            end
            if ~exist('k','var')
                k = 1:size(obj.data,1);
            end
            tPts = obj.data(k,1);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDuration(obj, duration, tPts)
            if isempty(obj.data)
                return;
            end
            if ~exist('duration','var')
                duration = 5;
            end
            if ~exist('tPts','var')
                tPts = obj.data(:,1);
            end
            k=[];
            for ii=1:length(tPts)
                k(ii) = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
            end
            obj.data(k,2) = duration;
        end

        
        % -------------------------------------------------------
        function duration = GetDuration(obj, tPts)
            duration = [];
            if isempty(obj.data)
                return;
            end
            if ~exist('tPts','var')
                tPts = obj.data(:,1);
            end
            k = [];
            for ii=1:length(tPts)
                k(ii) = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
            end            
            duration = obj.data(k,2);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetAmplitudes(obj, amps, tPts)
            if isempty(obj.data)
                return;
            end
            if ~exist('amps','var')
                amps = 1;
            end
            if ~exist('tPts','var')
                tPts = obj.data(:,1);
            end
            k=[];
            for ii=1:length(tPts)
                k(ii) = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
            end
            obj.data(k,3) = amps;
        end

        
        % -------------------------------------------------------
        function amps = GetAmplitudes(obj, tPts)
            amps = [];
            if isempty(obj.data)
                return;
            end
            if ~exist('tPts','var')
                tPts = obj.data(:,1);
            end
            k = [];
            for ii=1:length(tPts)
                k(ii) = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
            end
            amps = obj.data(k,3);
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts)
            if isempty(obj.data)
                return;
            end
            
            % Find all stims for any conditions which match the time points and 
            % delete them from data. 
            k = [];
            j = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin )];
                j = [j, find( abs(obj.states(:,1)-tPts(ii)) < obj.errmargin )];
            end
            obj.data(k,:) = [];
            obj.states(j,:) = [];
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts)
            if isempty(obj.data)
                return;
            end
            
            % Find all stims for any conditions which match the time points and 
            % flip their statuses
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.states(:,1)-tPts(ii)) < obj.errmargin )];
            end
            obj.states(k,2) = -1*obj.states(k,2);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.name)
                return;
            end
            if isempty(obj.data)
                return;
            end
            if all(obj.data(:)==0)
                return;
            end
            b = false;
        end
        
                
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return
            end
            nbytes = sizeof(obj.states) + sizeof(obj.name) + sizeof(obj.data) + sizeof(obj.GetFilename()) + sizeof(obj.GetFileFormat()) + sizeof(obj.GetSupportedFormats()) + 8;
        end
        
    end
    
end
