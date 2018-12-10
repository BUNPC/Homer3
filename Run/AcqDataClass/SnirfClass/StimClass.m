classdef StimClass  < matlab.mixin.Copyable
    
    properties
        filename
        name
        data
    end

    properties (Access = private)
        errmargin
        status
    end
    
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(varargin)
                        
            if nargin==3
                
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
            obj.errmargin = 1e-4;
            obj.status = 0;
            
        end
        
        
        % -------------------------------------------------------
        function err = Load(obj, fname, parent)

            err = 0;
            
            % Overwrite 1st argument if the property filename is NOT empty
            if ~isempty(obj.filename)
                fname = obj.filename;
            end
            
            % Arg 1
            if ~exist(fname, 'file')
                err = -1;
                return;
            end
            if ~exist(fname,'file')
                err = -1;
                return;
            end
                          
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/snirf/stim_1';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            try
                name = deblank(h5read(fname, [parent, '/name']));
                obj.name = name{1};
                obj.data = h5read(fname, [parent, '/data']);
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
        function ts = GetStim(obj)
            ts = [];
            if isempty(obj.data)
                return;
            end
            ts = obj.data(:,1);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDuration(obj, duration, tPts)
            if ~exist('duration','var')
                duration = 5;
            end
            if ~exist('tPts','var')
                tPts = obj.data(:,1);
            end
            for ii=1:length(tPts)
                k = find( abs(obj.data(:,1)-tPts(ii)) < obj.errmargin );
                if isempty(k)
                    continue;
                end
                obj.data(k,2) = duration;
            end
        end

        
        % -------------------------------------------------------
        function duration = GetDuration(obj, tPt)
            if ~exist('tPts','var')
                tPt = 1;
            end
            if isempty(obj.data)
                duration = [];
            else
                duration = obj.data(tPt,2);
            end
        end
        
    end
    
end
