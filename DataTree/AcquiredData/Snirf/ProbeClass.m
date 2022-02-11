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
    
    
    methods
        
        % -------------------------------------------------------
        function obj = ProbeClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.SetFileFormat('hdf5');
            
            % Set SNIRF fomat properties
            if nargin>0
                if isstruct(varargin{1})
                    SD = varargin{1};
                    obj.wavelengths = SD.Lambda;
                    obj.wavelengthsEmission  = [];
                    if isfield(SD,'SrcPos2D') &  ~isempty(SD.SrcPos2D)
                        obj.sourcePos2D  = SD.SrcPos2D;
                    else
                        obj.sourcePos2D  = SD.SrcPos;
                    end
                    if isfield(SD,'DetPos2D') & ~isempty(SD.DetPos2D)
                        obj.detectorPos2D  = SD.DetPos2D;
                    else
                        obj.detectorPos2D  = SD.DetPos;
                    end
                    if isfield(SD,'SrcPos3D') & ~isempty(SD.SrcPos3D)
                        obj.sourcePos3D  = SD.SrcPos3D;
                    else
                        obj.sourcePos3D  = SD.SrcPos;
                    end
                    if isfield(SD,'DetPos3D') & ~isempty(SD.DetPos3D)
                        obj.detectorPos3D  = SD.DetPos3D;
                    else
                        obj.detectorPos3D  = SD.DetPos;
                    end
                    if isfield(SD,'refpts')
                        obj.landmarkPos3D = SD.refpts.pos;
                        obj.landmarkLabels = SD.refpts.labels;
                        if isfield(SD,'refpts2D')
                            obj.landmarkPos2D = SD.refpts2D.pos;
                        end
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

        
        
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fileobj, location)
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
                obj.sourcePos2D               = HDF5_DatasetLoad(gid, 'sourcePos2D', [], '2D');
                obj.detectorPos2D             = HDF5_DatasetLoad(gid, 'detectorPos2D', [], '2D');
                obj.landmarkPos2D             = HDF5_DatasetLoad(gid, 'landmarkPos2D', [], '2D');
                obj.sourcePos3D               = HDF5_DatasetLoad(gid, 'sourcePos3D', [], '3D');
                obj.detectorPos3D             = HDF5_DatasetLoad(gid, 'detectorPos3D', [], '3D');
                obj.landmarkPos3D             = HDF5_DatasetLoad(gid, 'landmarkPos3D', [], '2D');
                obj.frequencies               = HDF5_DatasetLoad(gid, 'frequencies');
                obj.timeDelays                 = HDF5_DatasetLoad(gid, 'timeDelays');
                obj.timeDelayWidths            = HDF5_DatasetLoad(gid, 'timeDelayWidths');
                obj.momentOrders               = HDF5_DatasetLoad(gid, 'momentOrders');
                obj.correlationTimeDelays      = HDF5_DatasetLoad(gid, 'correlationTimeDelays');
                obj.correlationTimeDelayWidths = HDF5_DatasetLoad(gid, 'correlationTimeDelayWidths');
                obj.sourceLabels              = HDF5_DatasetLoad(gid, 'sourceLabels', obj.sourceLabels);
                obj.detectorLabels            = HDF5_DatasetLoad(gid, 'detectorLabels', obj.detectorLabels);
                obj.landmarkLabels            = HDF5_DatasetLoad(gid, 'landmarkLabels', obj.landmarkLabels);
                                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
                
                assert(obj.IsValid())
                
            catch 
                err=-1;
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
            
        end

        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location)
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
            
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            hdf5write_safe(fileobj, [location, '/wavelengths'], obj.wavelengths, 'array');
            hdf5write_safe(fileobj, [location, '/wavelengthsEmission'], obj.wavelengthsEmission, 'array');
            hdf5write_safe(fileobj, [location, '/sourcePos2D'], obj.sourcePos2D, 'array');
            hdf5write_safe(fileobj, [location, '/detectorPos2D'], obj.detectorPos2D, 'array');
            hdf5write_safe(fileobj, [location, '/landmarkPos2D'], obj.landmarkPos2D, 'array');
            hdf5write_safe(fileobj, [location, '/sourcePos3D'], obj.sourcePos3D, 'array');
            hdf5write_safe(fileobj, [location, '/detectorPos3D'], obj.detectorPos3D, 'array');
            hdf5write_safe(fileobj, [location, '/landmarkPos3D'], obj.landmarkPos3D, 'array');
            hdf5write_safe(fileobj, [location, '/frequencies'], obj.frequencies, 'array');
            hdf5write_safe(fileobj, [location, '/timeDelays'], obj.timeDelays, 'array');
            hdf5write_safe(fileobj, [location, '/timeDelayWidths'], obj.timeDelayWidths, 'array');
            hdf5write_safe(fileobj, [location, '/momentOrders'], obj.momentOrders, 'array');
            hdf5write_safe(fileobj, [location, '/correlationTimeDelays'], obj.correlationTimeDelays, 'array');
            hdf5write_safe(fileobj, [location, '/correlationTimeDelayWidths'], obj.correlationTimeDelayWidths, 'array');
            hdf5write_safe(fileobj, [location, '/sourceLabels'], obj.sourceLabels, 'array');
            hdf5write_safe(fileobj, [location, '/detectorLabels'], obj.detectorLabels, 'array');
            hdf5write_safe(fileobj, [location, '/landmarkLabels'], obj.landmarkLabels, 'array');
        end
        
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.wavelengths;
        end
        
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj,flag2d)
            if ~exist('flag2d','var')
                flag2d = 0;
            end
            if flag2d==0
                srcpos = obj.sourcePos3D;
            else
                srcpos = obj.sourcePos2D;
            end                
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj,flag2d)
            if ~exist('flag2d','var')
                flag2d = 0;
            end
            if flag2d==0
                detpos = obj.detectorPos3D;
            else
                detpos = obj.detectorPos2D;
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
                b = true;
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
        
    end
    
end
