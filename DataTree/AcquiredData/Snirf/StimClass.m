classdef StimClass < FileLoadSaveClass
    
    properties
        name
        data
        dataLabels
        states  % Stim marks enabled/disabled. Not part of SNIRF
    end
   
    % Properties not part of the SNIRF spec. These parameters aren't loaded or saved to files
    properties (Access = private)
        errmargin  % Margin for interpolating onset times. Not part of SNIRF
        debuglevel
    end    
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');
            obj.errmargin = 1e-2;
            obj.states = [];
            obj.debuglevel = DebugLevel('None');
            
            if nargin==1 
                if isa(varargin{1}, 'StimClass')
                    obj.Copy(varargin{1});
                elseif ischar(varargin{1})
                    % NOTE: exist can fail to work properly for the purposes of local group folder,
                    % if file name in question is somewhere (anywhere!) in the search path. Theerfore 
                    % we replace exist with our own function. 
                    if ispathvalid(varargin{1}, 'file')
                        obj.SetFilename(varargin{1});
                        obj.Load(varargin{1});
                    else
                        obj.name = varargin{1};
                        obj.data = [];
                        obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
                    end
                end
            elseif nargin==2
                if ischar(varargin{1})
                    obj.SetFilename(varargin{1});
                    obj.Load(varargin{1}, obj.fileformat, varargin{2});
                    % Note that states are not loaded from file
                else
                    t        = varargin{1};
                    CondName = varargin{2};
                    obj.name = CondName;
                    for ii=1:length(t)
                        obj.data(end+1,:) = [t(ii), 10, 1];
                    end
                    obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
                end
            elseif nargin==3
                s        = varargin{1};
                t        = varargin{2};
                CondName = varargin{3};
                obj.name = CondName;
                k = s>0 | s==-1 | s==-2;  % Include stim marks with these values
                obj.data = [t(k), 10*ones(length(t(k)),1), ones(length(t(k)),1)];
                obj.states = [t(k) s(k)];
                obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
            elseif nargin==0
                obj.name = '';
                obj.data = [];
                obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
            end
            obj.SortTpts();
            obj.updateStates();  % Generates enabled states to match the data array
        end
        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, location)
            
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~ispathvalid(fileobj,'file'))
                fileobj = '';
            end
                        
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/stim1';
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
               
            try 
                
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);

                % Absence of optional aux field raises error > 0
                if gid.double < 0
                    err = 1;
                    return;
                end
                
                % Load datasets
                obj.name   = HDF5_DatasetLoad(gid, 'name');
                obj.data   = HDF5_DatasetLoad(gid, 'data', [], '2D');
                obj.dataLabels   = HDF5_DatasetLoad(gid, 'dataLabels', {});
                if all(obj.data(:)==0)
                    obj.data = [];
                end
                if isempty(obj.dataLabels)
                    obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
                end
                err = obj.ErrorCheck();

                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
                
                obj.updateStates();
                
            catch
                
                if gid.double > 0
                    err = -2;
                else
                    err = 1;
                end
                
            end
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

            if ~ispathvalid(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            if obj.debuglevel.Get() == obj.debuglevel.SimulateBadData()
                obj.SimulateBadData();
            end
            
            hdf5write_safe(fileobj, [location, '/name'], obj.name);
            hdf5write_safe(fileobj, [location, '/data'], obj.data, 'array');
            hdf5write_safe(fileobj, [location, '/dataLabels'], obj.dataLabels);
        end
        
        
                
        % -------------------------------------------------------
        function Update(obj, fileobj, location)
            if ~ispathvalid(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fileobj, [location, '/name'], obj.name);
            hdf5write_safe(fileobj, [location, '/data'], obj.data, 'array');
            hdf5write_safe(fileobj, [location, '/dataLabels'], obj.dataLabels);
        end
        
        
        % -------------------------------------------------------
        function Copy(obj, obj2)
            obj.name = obj2.name;
            obj.data = obj2.data;
            if isempty(obj2.dataLabels)
                obj.dataLabels = {'Onset', 'Duration', 'Amplitude'};
                if length(obj.dataLabels) < size(obj.data, 2)
                    for i = 1:length(obj.dataLabels) - 3
                       obj.dataLabels{end + 1} = ''; 
                    end
                end
            else
                obj.dataLabels = obj2.dataLabels;
            end
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
                if ~isempty(obj.data) || ~isempty(obj2.data)
                    return;
                end
            end
            
            % Now check contents
            if ~all(obj.data(:)==obj2.data(:))
                return;
            end
            
            if length(obj.dataLabels) ~= length(obj2.dataLabels)
                return;
            end
            for ii = 1:length(obj.dataLabels)
                if ~strcmp(obj.dataLabels{ii}, obj2.dataLabels{ii})
                    return;
                end
            end
            B = true;
        end
        
        
        % -------------------------------------------------------
        function updateStates(obj)
            % Generate or regenerate a state list compatible with the data
            % array. Match up existing states with new list of time points
            if isempty(obj.data)
                return;
            elseif size(obj.states, 1) == size(obj.data, 1)
                obj.states(:, 1) = obj.data(:, 1);
                return;
            end
            old = obj.states;
            obj.states = ones(size(obj.data, 1), 2);
            for i=1:size(obj.data, 1)  % For each data row
                if ~isempty(old)
                    k = find(abs(obj.data(i, 1) - old(:, 1)) < obj.errmargin);
                else
                    k = []; 
                end
                if isempty(k) % If old state not there, generate new one
                    obj.states(i, :) = [obj.data(i, 1), 1];
                else % Get old state if it exists 
                    obj.states(i, :) = old(k, :);
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = ErrorCheck(obj)
            err = 0;
            
            % According to SNIRF spec, stim data is invalid if it has > 0 AND < 3 columns
            if isempty(obj.data)
                return;
            end
            if size(obj.data, 2)<3
                err = -2;
                return;
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
            obj.updateStates();
        end
        
        % -------------------------------------------------------
        function val = GetData(obj)
            val = obj.data;
        end

        % -------------------------------------------------------
        function SetStates(obj, states)
            obj.states = states;
            obj.updateStates();
        end
        
        
        % -------------------------------------------------------
        function val = GetStates(obj)
            val = obj.states;
        end

        
        % -------------------------------------------------------
        function SetDataLabels(obj, dataLabels)
            if length(dataLabels) < size(obj.data, 2)
               for i = 1:size(obj.data, 2) - length(dataLabels)
                  dataLabels{end + 1} = ''; 
               end
            end
            obj.dataLabels = dataLabels(1:size(obj.data, 2));
        end
        
        
        % -------------------------------------------------------
        function val = GetDataLabels(obj)
            val = obj.dataLabels;            
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
        function AddStims(obj, tPts, duration, amp, more)
            % Add one or more stims to with a given duration, amplitude, and additional
            % column data given by more
            if ~exist('duration','var')
                duration = 10;
            end
            if ~exist('amp','var')
                amp = 1;
            end
            if ~exist('more', 'var') | isempty(more)
               more = zeros(size(obj.data, 2) - 3);
            end
            if ~isempty(obj.data)
                if ~isempty(more) & length(more) > (size(obj.data, 2) - 3)
                    obj.data(:, end+length(more)) = 0;  % Pad to accomodate additional data columns 
                end
                for i=1:length(tPts)
                    if ~obj.Exists(tPts(i))
                        obj.data(end+1,:) = [tPts(i), duration, amp, more];
                        obj.states(end+1,:) = [tPts(i), 1];
                    end
                end 
            else  % If this stim is being added to an empty condition
                for i = 1:length(tPts)
                    obj.data(i,:) = [tPts(i), duration, amp, more];
                    obj.states(i,:) = [tPts(i), 1];
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
            obj.SortTpts();
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
            end
            obj.data(k,:) = [];
            obj.states(k,:) = [];
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts)
            if isempty(obj.data)
                return;
            end
            
            % Find all stims for any conditions which match the time points and 
            % flip their states
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.states(:,1)-tPts(ii)) < obj.errmargin )];
            end
            obj.states(k,2) = -1*obj.states(k,2);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function AddStimColumn(obj, name, initValue)
            if ~exist('name', 'var')
               name = ''; 
            end
            if ~exist('initValue', 'var')
               initValue = 0; 
            end
            obj.dataLabels{end + 1} = name;
            obj.data(:, end + 1) = initValue * ones(size(obj.data, 1), 1);
        end

        
        
        % ----------------------------------------------------------------------------------
        function DeleteStimColumn(obj, idx)
            if ~exist('idx', 'var') || idx <= size(obj.data, 2) - 3
                return;
            else
                obj.data(:, idx) = [];
                if length(obj.dataLabels) >= idx
                   obj.dataLabels(idx) = []; 
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function RenameStimColumn(obj, oldname, newname)
            if ~exist('oldname', 'var') || ~exist('newname', 'var')
                return;
            end
            for i = 1:length(obj.dataLabels)
                if strcmp(oldname, obj.dataLabels{i})
                   obj.dataLabels{i} = newname;
                end
            end
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
        function SortTpts(obj)
            try
                [~, idx] = sort(obj.data(:, 1));
                obj.data = obj.data(idx, :);
                obj.states = obj.states(idx, :);
            catch  % Index error
               return; 
            end
        end
           
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return
            end
            nbytes = sizeof(obj.states) + sizeof(obj.name) + sizeof(obj.data) + sizeof(obj.GetFilename()) + sizeof(obj.GetFileFormat()) + sizeof(obj.GetSupportedFormats()) + 8;
        end

               
        % ----------------------------------------------------------------------------------
        function SimulateBadData(obj)
            onsets = 10:20.2:100;
            obj.data = [onsets(:), zeros(length(onsets),1)];
        end
        
        
    end
    
end
