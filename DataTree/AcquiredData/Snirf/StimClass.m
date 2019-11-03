classdef StimClass < FileLoadSaveClass
    
    properties
        name
        data
    end
   
    % Properties not part of the SNIRF spec. These parameters aren't loaded or saved to files
    properties (Access = private)
        errmargin
    end    
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(varargin)
            if nargin==1 
                if isa(varargin{1}, 'StimClass')
                    obj.Copy(varargin{1});
                elseif ischar(varargin{1})
                    obj.name = varargin{1};
                    obj.data = [];
                end
            elseif nargin==3
                s        = varargin{1};
                t        = varargin{2};
                CondName = varargin{3};
                obj.name = CondName;
                k = s>0;
                obj.data = [t(k), 5*ones(length(t(k)),1), ones(length(t(k)),1)];
            elseif nargin==2
                t        = varargin{1};
                CondName = varargin{2};
                obj.name = CondName;
                for ii=1:length(t)
                    obj.data(end+1,:) = [t(ii), 5, 1];
                end
            elseif nargin==0
                obj.name = '';
                obj.data = [];
            end
            
            % Set class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';
            obj.errmargin = 1e-3;
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
                parent = '/nirs/stim1';
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
                obj.name = convertH5StrToStr(h5read(fname, [parent, '/name']));
                obj.data = h5read(fname, [parent, '/data']);
            catch
                err = -1;
                return;
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
            
            % Since this is a writable and variable size parameter, we want to 
            % use h5create and specify 'Inf' for the number of rows to
            % indicate variable number of rows
            h5create(fname, [parent, '/data'], [Inf,3],'ChunkSize',[3,3]);
            if ~isempty(obj.data)
                h5write(fname,[parent, '/data'], obj.data, [1,1], size(obj.data));
            end
        end
        
        
        
        % -------------------------------------------------------
        function Update(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fname, [parent, '/name'], obj.name);
            h5write_safe(fname, [parent, '/data'], obj.data);
        end
        
        
        % -------------------------------------------------------
        function Copy(obj, obj2)
            obj.name = obj2.name;
            obj.data = obj2.data;
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            if ~all(obj.data(:)==obj2.data(:))
                return;
            end
            B = true;
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
        function AddStims(obj, tPts, duration, val)
            if ~exist('duration','var')
                duration = 5;
            end
            if ~exist('val','var')
                val = 1;
            end
            for ii=1:length(tPts)
                if ~obj.Exists(tPts(ii))
                    obj.data(end+1,:) = [tPts(ii), duration, val];
                end
            end
        end

        
        % ----------------------------------------------------------------------------------
        function EditValue(obj, tPts, val)
            if isempty(obj.data)
                return;
            end
            if ~exist('val','var')
                val = 1;
            end
            for ii=1:length(tPts)
                k = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
                obj.data(k,3) = val;
            end
        end

        
        % -------------------------------------------------------
        function [ts, v] = GetStim(obj)
            ts = [];
            v = [];
            if isempty(obj.data)
                return;
            end
            ts = obj.data(:,1);
            v = obj.data(:,3);
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
        function SetValues(obj, vals, tPts)
            if isempty(obj.data)
                return;
            end
            if ~exist('vals','var')
                vals = 1;
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
            obj.data(k,3) = vals;
        end

        
        % -------------------------------------------------------
        function vals = GetValues(obj, tPts)
            vals = [];
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
            vals = obj.data(k,3);
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts)
            if isempty(obj.data)
                return;
            end
            
            % Find all stims for any conditions which match the time points and 
            % delete them from data. 
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin )];
            end
            obj.data(k,:) = [];
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts)
            if isempty(obj.data)
                return;
            end
            
            % Find all stims for any conditions which match the time points and 
            % flip it's value.
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin )];
            end
            obj.data(k,3) = -1*obj.data(k,3);
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
            b = false;
        end
        
                
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = sizeof(obj.name) + sizeof(obj.data);
        end
        
    end
    
end
