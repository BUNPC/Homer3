classdef ProbeClass < FileLoadSaveClass
    
    properties
        wavelengths
        wavelengthsEmission
        sourcePos2D
        detectorPos2D
        landmarkPos2D
        landmarkPos3D
        sourcePos3D
        detectorPos3D
        frequencies
        timeDelays
        timeDelayWidths
        momentOrders
        correlationTimeDelays
        correlationTimeDelayWidths
        sourceLabels
        detectorLabels
        landmarkLabels
    end
    
    properties (Access = private)
        scaling
    end
    
    
    
    methods
        
        % -------------------------------------------------------
        function obj = ProbeClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');
            obj.scaling = 1;            
            
            % Set SNIRF fomat properties
            if nargin>0
                if isstruct(varargin{1})
                    n = NirsClass(varargin{1});
                    SD = n.SD;
                    obj.wavelengths = SD.Lambda;
                    obj.wavelengthsEmission  = [];
                    if isfield(SD,'SrcPos2D') &&  ~isempty(SD.SrcPos2D)
                        obj.sourcePos2D  = SD.SrcPos2D;
                    else
                        obj.sourcePos2D  = SD.SrcPos;
                    end
                    if isfield(SD,'DetPos2D') && ~isempty(SD.DetPos2D)
                        obj.detectorPos2D  = SD.DetPos2D;
                    else
                        obj.detectorPos2D  = SD.DetPos;
                    end
                    if isfield(SD,'SrcPos3D') && ~isempty(SD.SrcPos3D)
                        obj.sourcePos3D  = SD.SrcPos3D;
                    else
                        obj.sourcePos3D  = SD.SrcPos;
                    end
                    if isfield(SD,'DetPos3D') && ~isempty(SD.DetPos3D)
                        obj.detectorPos3D  = SD.DetPos3D;
                    else
                        obj.detectorPos3D  = SD.DetPos;
                    end
                    if isfield(SD,'Landmarks3D')
                        obj.landmarkPos3D = SD.Landmarks3D.pos;
                        obj.landmarkLabels = SD.Landmarks3D.labels;
                        if isfield(SD,'Landmarks2D')
                            obj.landmarkPos2D = SD.Landmarks2D.pos;
                        end
                    else
                        obj.landmarkPos3D = SD.DummyPos;
                        obj.landmarkLabels = SD.Landmarks3D.labels;
                    end
                    obj.frequencies  = 1;
                    obj.timeDelays  = 0;
                    obj.timeDelayWidths  = 0;
                    obj.momentOrders = [];
                    obj.correlationTimeDelays = 0;
                    obj.correlationTimeDelayWidths = 0;
                    for ii=1:size(SD.SrcPos)
                        obj.sourceLabels{ii} = ['S',num2str(ii)];
                    end
                    for ii=1:size(SD.DetPos)
                        obj.detectorLabels{ii} = ['D',num2str(ii)];
                    end
                elseif ischar(varargin{1})
                    obj.SetFilename(varargin{1});
                    obj.Load(varargin{1});
                end
            else
                obj.wavelengths          = [];
                obj.wavelengthsEmission  = [];
                obj.sourcePos2D  = [];
                obj.detectorPos2D  = [];
                obj.sourcePos3D  = [];
                obj.detectorPos3D  = [];
                obj.frequencies  = 1;
                obj.timeDelays  = 0;
                obj.timeDelayWidths  = 0;
                obj.momentOrders = [];
                obj.correlationTimeDelays = 0;
                obj.correlationTimeDelayWidths = 0;
                obj.sourceLabels = {};
                obj.detectorLabels = {};
            end
        end

        
        
        % -------------------------------------------------------
        function ForwardCompatibility(obj)
            if size(obj.sourcePos2D,2)<3
                obj.sourcePos2D       = [obj.sourcePos2D, zeros(size(obj.sourcePos2D,1), 1)];
            end
            if size(obj.detectorPos2D,2)<3
                obj.detectorPos2D     = [obj.detectorPos2D, zeros(size(obj.detectorPos2D,1), 1)];
            end
        end

        
        
        % -------------------------------------------------------
        function BackwardCompatibility(obj)
            if isempty(obj.sourcePos2D)
                obj.sourcePos2D   = HDF5_DatasetLoad(gid, 'sourcePos', [], '2D');
            end
            if isempty(obj.detectorPos2D)
                obj.detectorPos2D = HDF5_DatasetLoad(gid, 'detectorPos', [], '2D');
            end
            if isempty(obj.landmarkPos2D)
                obj.landmarkPos2D = HDF5_DatasetLoad(gid, 'landmarkPos', [], '2D');
            end
        end
        
        
        
        % ----------------------------------------------
        function isValid = isValidLandmarkLabels(obj)
            isValid = 1;
            refpts_labels = {'T7','T8','Oz','Fpz','Cz','C3','C4','Pz','Fz'};
            for u = 1:length(refpts_labels)
                label = refpts_labels{u};
                idx = ismember(obj.landmarkLabels, label);
                if sum(idx) == 0
                    isValid = 0;
                    return
                end
            end 
        end

        
        
        % -------------------------------------------------------
        function Project_3D_to_2D(obj)             
            if isempty(obj.sourcePos2D) && isempty(obj.detectorPos2D)
                if isempty(obj.landmarkPos3D) || ~obj.isValidLandmarkLabels()
                    nSource = size(obj.sourcePos3D,1);
                    optodePos3D = [obj.sourcePos3D; obj.detectorPos3D];
                    
                    optodePos2D = project_3D_to_2D(optodePos3D);
                    if ~isempty(optodePos2D)
                        if nSource ~= 0
                            obj.sourcePos2D = optodePos2D(1:nSource,:);
                        end
                        if size(optodePos3D,1) > nSource
                            obj.detectorPos2D = optodePos2D(nSource+1:end,:);
                        end
                    end
                else
                     if ~isempty(obj.sourcePos3D) && ~isempty(obj.detectorPos3D)
                        [sphere.label, sphere.theta, sphere.phi, sphere.r, sphere.xc, sphere.yc, sphere.zc] = textread('10-5-System_Mastoids_EGI129.csd','%s %f %f %f %f %f %f','commentstyle','c++');
                        % ref pt labels used for affine transformation
                        refpts_labels = {'T7','T8','Oz','Fpz','Cz','C3','C4','Pz','Fz'};

                        % get positions for refpts_labels from both sphere and probe ref pts
                        for u = 1:length(refpts_labels)
                            label = refpts_labels{u};

                            idx = ismember(obj.landmarkLabels, label);
                            if isempty(idx)
                                return
                            end
                            probe_refps_pos(u,:) = obj.landmarkPos3D(idx,:);
                            idx = ismember(sphere.label, label);
                            sphere_refpts_pos(u,:) = [sphere.xc(idx) sphere.yc(idx) sphere.zc(idx)];
                        end

                        % get affine transformation
                        % probe_refps*T = sphere_refpts
                        probe_refps_pos = [probe_refps_pos(:,1:3) ones(size(probe_refps_pos,1),1)];
                        T = probe_refps_pos\sphere_refpts_pos;

                        % tranform optode positions onto unit sphere.
                        % opt_pos = probe.optpos_reg;
                        % opt_pos = [opt_pos ones(size(opt_pos,1),1)];
                        % sphere_opt_pos = opt_pos*T;
                        % sphere_opt_pos_norm = sqrt(sum(sphere_opt_pos.^2,2));
                        % sphere_opt_pos = sphere_opt_pos./sphere_opt_pos_norm ;
                        %
                        % get 2D circular refpts for current selecetd reference point system
                        probe_refpts_idx =  ismember(sphere.label, obj.landmarkLabels);

                        % refpts_2D.pos = [sphere_xc(probe_refpts_idx) sphere_yc(probe_refpts_idx) sphere_zc(probe_refpts_idx)];
                        refpts_2D.label = sphere.label(probe_refpts_idx);
                        %
                        refpts_theta =  sphere.theta(probe_refpts_idx);
                        refpts_phi = 90 - sphere.phi(probe_refpts_idx); % elevation angle from top axis

                        refpts_theta = (2 * pi * refpts_theta) / 360; % convert to radians
                        refpts_phi = (2 * pi * refpts_phi) / 360;
                        [x,y] = pol2cart(refpts_theta, refpts_phi);      % get plane coordinates
                        xy = [x y];

                        %
                        norm_factor = max(max(xy));
                        xy = xy/norm_factor;               % set maximum to unit length
                        refpts_2D.pos = xy;
                        obj.landmarkPos2D = refpts_2D.pos;

                        %
                        obj.sourcePos2D = convert_optodepos_to_circlular_2D_pos(obj.sourcePos3D, T, norm_factor);
                        obj.detectorPos2D = convert_optodepos_to_circlular_2D_pos(obj.detectorPos3D, T, norm_factor);
                    end
                end
            end
        end

        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, location, LengthUnit)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~exist(fileobj,'file'))
                fileobj = '';
            end
                        
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/probe';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            % Arg3
            if exist('LengthUnit','var')
                % Figure out the scaling factor to multiple by to get the coorinates to be in mm units
                if strcmpi(LengthUnit,'m')  % meter units
                    obj.scaling = 1000;
                elseif strcmpi(LengthUnit,'cm')  % centimeter units
                    obj.scaling = 10;
                end
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
                obj.wavelengths               = HDF5_DatasetLoad(gid, 'wavelengths');
                obj.wavelengthsEmission       = HDF5_DatasetLoad(gid, 'wavelengthsEmission');
                obj.sourcePos2D               = HDF5_DatasetLoad(gid, 'sourcePos2D', [], '2D') * obj.scaling;
                obj.detectorPos2D             = HDF5_DatasetLoad(gid, 'detectorPos2D', [], '2D') * obj.scaling;
                obj.landmarkPos2D             = HDF5_DatasetLoad(gid, 'landmarkPos2D', [], '2D') * obj.scaling;
                obj.sourcePos3D               = HDF5_DatasetLoad(gid, 'sourcePos3D', [], '3D') * obj.scaling;
                obj.detectorPos3D             = HDF5_DatasetLoad(gid, 'detectorPos3D', [], '3D') * obj.scaling;
                obj.landmarkPos3D             = HDF5_DatasetLoad(gid, 'landmarkPos3D', [], '2D') * obj.scaling;
                obj.frequencies               = HDF5_DatasetLoad(gid, 'frequencies');
                obj.timeDelays                 = HDF5_DatasetLoad(gid, 'timeDelays');
                obj.timeDelayWidths            = HDF5_DatasetLoad(gid, 'timeDelayWidths');
                obj.momentOrders               = HDF5_DatasetLoad(gid, 'momentOrders');
                obj.correlationTimeDelays      = HDF5_DatasetLoad(gid, 'correlationTimeDelays');
                obj.correlationTimeDelayWidths = HDF5_DatasetLoad(gid, 'correlationTimeDelayWidths');
                obj.sourceLabels              = HDF5_DatasetLoad(gid, 'sourceLabels', obj.sourceLabels);
                obj.detectorLabels            = HDF5_DatasetLoad(gid, 'detectorLabels', obj.detectorLabels);
                obj.landmarkLabels            = HDF5_DatasetLoad(gid, 'landmarkLabels', obj.landmarkLabels);
                
                obj.Project_3D_to_2D();
                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
                
                assert(obj.IsValid())
                
            catch 
                err = -1;
                return;
            end
            
            % Call method to change future current and future versions of
            % SNIRF data to Homer3 compatible structure
            obj.ForwardCompatibility();
            
            % for Homer3 usage, add 3D positions if they are empty
            if isempty(obj.sourcePos3D)
                obj.sourcePos3D = obj.sourcePos2D;
                if size(obj.sourcePos3D,2)<3
                    obj.sourcePos3D(:,3) = 0;
                end
            end
            
            if isempty(obj.detectorPos3D)
                obj.detectorPos3D = obj.detectorPos2D;
                if size(obj.detectorPos3D,2)<3
                    obj.detectorPos3D(:,3) = 0;
                end
            end
            obj.SetError(err); 
        end

        
        
        % -------------------------------------------------------
        function err = SaveHdf5(obj, fileobj, location)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/probe';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            % Convert file object to HDF5 file descriptor
            fid = HDF5_GetFileDescriptor(fileobj);
            if fid < 0
                err = -1;
                return;
            end
                        
            % Multiple all coordinates by reciprocal of scaling factor when saving to get the 
            % coordinates back to original.
            obj.sourcePos2D    = obj.sourcePos2D / obj.scaling;
            obj.detectorPos2D  = obj.detectorPos2D / obj.scaling;
            obj.landmarkPos2D  = obj.landmarkPos2D / obj.scaling;
            obj.sourcePos3D    = obj.sourcePos3D / obj.scaling;
            obj.detectorPos3D  = obj.detectorPos3D / obj.scaling;
            obj.landmarkPos3D  = obj.landmarkPos3D / obj.scaling;
            
            % Now save
            hdf5write_safe(fid, [location, '/wavelengths'], obj.wavelengths, 'array');
            hdf5write_safe(fid, [location, '/wavelengthsEmission'], obj.wavelengthsEmission, 'array');
            hdf5write_safe(fid, [location, '/sourcePos2D'], obj.sourcePos2D, 'array');
            hdf5write_safe(fid, [location, '/detectorPos2D'], obj.detectorPos2D, 'array');
            hdf5write_safe(fid, [location, '/landmarkPos2D'], obj.landmarkPos2D, 'array');
            hdf5write_safe(fid, [location, '/sourcePos3D'], obj.sourcePos3D, 'array');
            hdf5write_safe(fid, [location, '/detectorPos3D'], obj.detectorPos3D, 'array');
            hdf5write_safe(fid, [location, '/landmarkPos3D'], obj.landmarkPos3D, 'array');
            hdf5write_safe(fid, [location, '/frequencies'], obj.frequencies, 'array');
            hdf5write_safe(fid, [location, '/timeDelays'], obj.timeDelays, 'array');
            hdf5write_safe(fid, [location, '/timeDelayWidths'], obj.timeDelayWidths, 'array');
            hdf5write_safe(fid, [location, '/momentOrders'], obj.momentOrders, 'array');
            hdf5write_safe(fid, [location, '/correlationTimeDelays'], obj.correlationTimeDelays, 'array');
            hdf5write_safe(fid, [location, '/correlationTimeDelayWidths'], obj.correlationTimeDelayWidths, 'array');
            hdf5write_safe(fid, [location, '/sourceLabels'], obj.sourceLabels, 'array');
            hdf5write_safe(fid, [location, '/detectorLabels'], obj.detectorLabels, 'array');
            hdf5write_safe(fid, [location, '/landmarkLabels'], obj.landmarkLabels, 'array');
        end
        
        
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.wavelengths;
        end
        
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj, options) %#ok<*INUSD>
            if ~exist('options','var')
                options = '';
            end
            if optionExists(options,'2D')
                if ~isempty(obj.sourcePos2D)
                    srcpos = obj.sourcePos2D;
                else
                    srcpos = obj.sourcePos3D;
                end
            else
                if ~isempty(obj.sourcePos3D)
                    srcpos = obj.sourcePos3D;
                else
                    srcpos = obj.sourcePos2D;
                end
            end
        end
        
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj, options)
            if ~exist('options','var')
                options = '';
            end
            if optionExists(options,'2D')
                if ~isempty(obj.detectorPos2D)
                    detpos = obj.detectorPos2D;
                else
                    detpos = obj.detectorPos3D;
                end
            else
	            if ~isempty(obj.detectorPos3D)
	                detpos = obj.detectorPos3D;
	            else
	                detpos = obj.detectorPos2D;
	            end
	        end
        end
        
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if isempty(obj) && ~isempty(obj2)
                return;
            end
            if isempty(obj) && ~isempty(obj2)
                return;
            end
            if ~isempty(obj) && isempty(obj2)
                return;
            end
            if isempty(obj) && isempty(obj2)
                return;
            end
            if ~all(obj.wavelengths(:)==obj2.wavelengths(:))
                return;
            end
            if ~all(obj.wavelengthsEmission(:)==obj2.wavelengthsEmission(:))
                return;
            end
            if ~all(obj.sourcePos2D(:)==obj2.sourcePos2D(:))
                return;
            end
            if ~all(obj.detectorPos2D(:)==obj2.detectorPos2D(:))
                return;
            end
            if ~all(obj.sourcePos3D(:)==obj2.sourcePos3D(:))
                return;
            end
            if ~all(obj.detectorPos3D(:)==obj2.detectorPos3D(:))
                return;
            end
            if ~all(obj.frequencies(:)==obj2.frequencies(:))
                return;
            end
            if ~all(obj.timeDelays(:)==obj2.timeDelays(:))
                return;
            end
            if ~all(obj.timeDelayWidths(:)==obj2.timeDelayWidths(:))
                return;
            end
            if ~all(obj.momentOrders(:)==obj2.momentOrders(:))
                return;
            end
            if ~all(obj.correlationTimeDelays(:)==obj2.correlationTimeDelays(:))
                return;
            end
            if ~all(obj.correlationTimeDelayWidths(:)==obj2.correlationTimeDelayWidths(:))
                return;
            end
            if length(obj.sourceLabels)~=length(obj2.sourceLabels)
                return;
            end
            for ii=1:length(obj.sourceLabels)
                if ~strcmp(obj.sourceLabels{ii}, obj2.sourceLabels{ii})
                    return;
                end
            end
            if length(obj.detectorLabels)~=length(obj2.detectorLabels)
                return;
            end
            for ii=1:length(obj.detectorLabels)
                if ~strcmp(obj.detectorLabels{ii}, obj2.detectorLabels{ii})
                    return;
                end
            end
            B = true;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            fields = properties(obj);
            for ii=1:length(fields)
                nbytes = nbytes + eval(sprintf('sizeof(obj.%s)', fields{ii}));
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj.wavelengths)
                return;
            end
            if isempty(obj.sourcePos2D) && isempty(obj.detectorPos2D) && ...
                    isempty(obj.sourcePos3D) && isempty(obj.detectorPos3D) 
                return;
            end
            b = false;
        end

        
        
        % ----------------------------------------------------------------------------------
        function b = IsValid(obj)
            b = false;
            if obj.IsEmpty()
                return;
            end
            if iscolumn(obj.sourcePos2D)
                return;
            end
            if length(obj.sourcePos2D)>4
                if size(obj.sourcePos2D,2) > size(obj.sourcePos2D,1)
                    return;
                end
            end
            if iscolumn(obj.detectorPos2D)
                return;
            end
            if length(obj.detectorPos2D)>4
                if size(obj.detectorPos2D,2) > size(obj.detectorPos2D,1)
                    return;
                end
            end
            b = true;
        end
        
        
        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = [];
            
            optpos = [obj.GetSrcPos('2D'); obj.GetDetPos('2D')];
            if isempty(optpos)
                return
            end
            
            xmax = max(optpos(:,1));
            ymax = max(optpos(:,2));

            xmin = min(optpos(:,1));
            ymin = min(optpos(:,2));
            
            width = xmax-xmin;
            height = ymax-ymin;
            
            if width==0
                width = 1;
            end
            if height==0
                height = 1;
            end
            
            px = width * 0.05; 
            py = height * 0.05; 

            bbox = [xmin-px, xmax+px, ymin-py, ymax+py];
        end
        
        
        % ---------------------------------------------------------
        function val = GetScaleFactor(obj)
            val = obj.scaling;
        end
        
        
    end
    
end
