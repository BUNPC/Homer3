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
        function obj = LoadHdf5(obj, fname, parent)
            % Overwrite 1st argument if the property filename is NOT empty
            if ~isempty(obj.filename)
                fname = obj.filename;
            end
            
            % Arg 1
            if ~exist('fname','var')
                return;
            end
            if ~exist(fname,'file')
                return;
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/nirs/probe';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
              
            obj.wavelengths               = hdf5read_safe(fname, [parent, '/wavelengths'], obj.wavelengths);
            obj.wavelengthsEmission       = hdf5read_safe(fname, [parent, '/wavelengthsEmission'], obj.wavelengthsEmission);
            obj.sourcePos                 = hdf5read_safe(fname, [parent, '/sourcePos'], obj.sourcePos);
            obj.detectorPos               = hdf5read_safe(fname, [parent, '/detectorPos'], obj.detectorPos);
            obj.frequency                 = hdf5read_safe(fname, [parent, '/frequency'], obj.frequency);
            obj.timeDelay                 = hdf5read_safe(fname, [parent, '/timeDelay'], obj.timeDelay);
            obj.timeDelayWidth            = hdf5read_safe(fname, [parent, '/timeDelayWidth'], obj.timeDelayWidth);
            obj.momentOrder               = hdf5read_safe(fname, [parent, '/momentOrder'], obj.momentOrder);
            obj.correlationTimeDelay      = hdf5read_safe(fname, [parent, '/correlationTimeDelay'], obj.correlationTimeDelay);
            obj.correlationTimeDelayWidth = hdf5read_safe(fname, [parent, '/correlationTimeDelayWidth'], obj.correlationTimeDelayWidth);
            obj.sourceLabels              = convertH5StrToStr(h5read_safe(fname, [parent, '/sourceLabels'], obj.sourceLabels));
            obj.detectorLabels            = convertH5StrToStr(h5read_safe(fname, [parent, '/detectorLabels'], obj.detectorLabels));
            
        end

        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            hdf5write_safe(fname, [parent, '/wavelengths'], obj.wavelengths);
            hdf5write_safe(fname, [parent, '/wavelengthsEmission'], obj.wavelengthsEmission);
            h5write_safe(fname, [parent, '/sourcePos'], obj.sourcePos);
            h5write_safe(fname, [parent, '/detectorPos'], obj.detectorPos);
            hdf5write(fname, [parent, '/frequency'], obj.frequency, 'WriteMode','append');
            hdf5write(fname, [parent, '/timeDelay'], obj.timeDelay, 'WriteMode','append');
            hdf5write(fname, [parent, '/timeDelayWidth'], obj.timeDelayWidth, 'WriteMode','append');
            hdf5write_safe(fname, [parent, '/momentOrder'], obj.momentOrder);
            hdf5write(fname, [parent, '/correlationTimeDelay'], obj.correlationTimeDelay, 'WriteMode','append');
            hdf5write(fname, [parent, '/correlationTimeDelayWidth'], obj.correlationTimeDelayWidth, 'WriteMode','append');
            hdf5write_safe(fname, [parent, '/sourceLabels'], obj.sourceLabels);
            hdf5write_safe(fname, [parent, '/detectorLabels'], obj.detectorLabels);
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
        
    end
    
end
