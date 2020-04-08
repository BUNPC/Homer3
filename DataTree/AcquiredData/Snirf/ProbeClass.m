classdef ProbeClass < FileLoadSaveClass
    
    properties
        wavelengths
        wavelengthsEmission
        sourcePos
        detectorPos
        frequency
        timeDelay
        timeDelayWidth
        momentOrder
        correlationTimeDelay
        correlationTimeDelayWidth
        sourceLabels
        detectorLabels
    end
    
    
    methods
        
        % -------------------------------------------------------
        function obj = ProbeClass(varargin)
            % Set class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';
            
            % Set SNIRF fomat properties
            if nargin>0
                if isstruct(varargin{1})
                    SD = varargin{1};
                    obj.wavelengths = SD.Lambda;
                    obj.wavelengthsEmission  = [];
                    obj.sourcePos  = SD.SrcPos;
                    obj.detectorPos  = SD.DetPos;
                    obj.frequency  = 1;
                    obj.timeDelay  = 0;
                    obj.timeDelayWidth  = 0;
                    obj.momentOrder = [];
                    obj.correlationTimeDelay = 0;
                    obj.correlationTimeDelayWidth = 0;
                    for ii=1:size(SD.SrcPos)
                        obj.sourceLabels{ii} = ['S',num2str(ii)];
                    end
                    for ii=1:size(SD.DetPos)
                        obj.detectorLabels{ii} = ['D',num2str(ii)];
                    end
                elseif ischar(varargin{1})
                    obj.filename = varargin{1};
                    obj.Load(varargin{1});
                end
            else
                obj.wavelengths          = [];
                obj.wavelengthsEmission  = [];
                obj.sourcePos  = [];
                obj.detectorPos  = [];
                obj.frequency  = 1;
                obj.timeDelay  = 0;
                obj.timeDelayWidth  = 0;
                obj.momentOrder = [];
                obj.correlationTimeDelay = 0;
                obj.correlationTimeDelayWidth = 0;
                obj.sourceLabels = {};
                obj.detectorLabels = {};
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
            if ~exist('location', 'var')
                location = '/nirs/probe';
            elseif location(1)~='/'
                location = ['/',location];
            end
              
            % Error checking            
            if ~isempty(fileobj) && ischar(fileobj)
                obj.filename = fileobj;
            elseif isempty(fileobj)
                fileobj = obj.filename;
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
                obj.sourcePos                 = HDF5_DatasetLoad(gid, 'sourcePos');
                obj.detectorPos               = HDF5_DatasetLoad(gid, 'detectorPos');
                obj.frequency                 = HDF5_DatasetLoad(gid, 'frequency');
                obj.timeDelay                 = HDF5_DatasetLoad(gid, 'timeDelay');
                obj.timeDelayWidth            = HDF5_DatasetLoad(gid, 'timeDelayWidth');
                obj.momentOrder               = HDF5_DatasetLoad(gid, 'momentOrder');
                obj.correlationTimeDelay      = HDF5_DatasetLoad(gid, 'correlationTimeDelay');
                obj.correlationTimeDelayWidth = HDF5_DatasetLoad(gid, 'correlationTimeDelayWidth');
                sourceLabels                  = HDF5_DatasetLoad(gid, 'sourceLabels')'; %#ok<*PROPLC>
                detectorLabels                = HDF5_DatasetLoad(gid, 'detectorLabels')';

                
                for ii=1:size(sourceLabels,1)
                    obj.sourceLabels{ii} = convertH5StrToStr(sourceLabels(ii,:)); 
                end
                for ii=1:size(detectorLabels,1)
                    obj.detectorLabels{ii} = convertH5StrToStr(detectorLabels(ii,:)); 
                end
                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
            catch 
                err=-1;
                return;
            end
        end

        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location)
            % Arg 1
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            hdf5write_safe(fileobj, [location, '/wavelengths'], obj.wavelengths);
            hdf5write_safe(fileobj, [location, '/wavelengthsEmission'], obj.wavelengthsEmission);
            h5write_safe(fileobj, [location, '/sourcePos'], obj.sourcePos);
            h5write_safe(fileobj, [location, '/detectorPos'], obj.detectorPos);
            hdf5write(fileobj, [location, '/frequency'], obj.frequency, 'WriteMode','append');
            hdf5write(fileobj, [location, '/timeDelay'], obj.timeDelay, 'WriteMode','append');
            hdf5write(fileobj, [location, '/timeDelayWidth'], obj.timeDelayWidth, 'WriteMode','append');
            hdf5write_safe(fileobj, [location, '/momentOrder'], obj.momentOrder);
            hdf5write(fileobj, [location, '/correlationTimeDelay'], obj.correlationTimeDelay, 'WriteMode','append');
            hdf5write(fileobj, [location, '/correlationTimeDelayWidth'], obj.correlationTimeDelayWidth, 'WriteMode','append');
            hdf5write_safe(fileobj, [location, '/sourceLabels'], obj.sourceLabels);
            hdf5write_safe(fileobj, [location, '/detectorLabels'], obj.detectorLabels);
        end
        
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.wavelengths;
        end
        
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            srcpos = obj.sourcePos;
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            detpos = obj.detectorPos;
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~all(obj.wavelengths(:)==obj2.wavelengths(:))
                return;
            end
            if ~all(obj.wavelengthsEmission(:)==obj2.wavelengthsEmission(:))
                return;
            end
            if ~all(obj.sourcePos(:)==obj2.sourcePos(:))
                return;
            end
            if ~all(obj.detectorPos(:)==obj2.detectorPos(:))
                return;
            end
            if ~all(obj.frequency(:)==obj2.frequency(:))
                return;
            end
            if ~all(obj.timeDelay(:)==obj2.timeDelay(:))
                return;
            end
            if ~all(obj.timeDelayWidth(:)==obj2.timeDelayWidth(:))
                return;
            end
            if ~all(obj.momentOrder(:)==obj2.momentOrder(:))
                return;
            end
            if ~all(obj.correlationTimeDelay(:)==obj2.correlationTimeDelay(:))
                return;
            end
            if ~all(obj.correlationTimeDelayWidth(:)==obj2.correlationTimeDelayWidth(:))
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
        
    end
    
end
