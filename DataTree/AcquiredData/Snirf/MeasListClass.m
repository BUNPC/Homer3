classdef MeasListClass < FileLoadSaveClass
    
    % Properties implementing the MeasList fields from the SNIRF spec
    properties
        sourceIndex
        detectorIndex
        wavelengthIndex
        dataType
        dataTypeIndex
        sourcePower
        sourcePowerUnit 
        detectorGain
    end
    
    methods

        function obj = MeasListClass(ml)
            obj.dataType         = 1;
            obj.dataTypeIndex    = 1;
            obj.sourcePower      = 0;
            obj.sourcePowerUnit  = '';
            obj.detectorGain     = 0;

            if nargin>0
                obj.sourceIndex      = ml(1);
                obj.detectorIndex    = ml(2);
                obj.wavelengthIndex  = ml(4);
            else
                obj.sourceIndex      = 0;
                obj.detectorIndex    = 0;
                obj.wavelengthIndex  = 0;
            end
        end
        
        
        % -------------------------------------------------------
        function obj = LoadHdf5(obj, fname, parent)
            err = 0;
            
            % Arg 1
            if ~exist('fname','var') || ~exist(fname,'file')
                fname = '';
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/snirf/ml_1';
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
            obj.sourceIndex = hdf5read(fname, [parent, '/sourceIndex']);
            obj.detectorIndex = hdf5read(fname, [parent, '/detectorIndex']);
            obj.wavelengthIndex = hdf5read(fname, [parent, '/wavelengthIndex']);
            obj.dataType = hdf5read(fname, [parent, '/dataType']);
            obj.dataTypeIndex = hdf5read(fname, [parent, '/dataTypeIndex']);
            obj.sourcePower = hdf5read(fname, [parent, '/sourcePower']);
            obj.detectorGain = hdf5read(fname, [parent, '/detectorGain']);
        end

        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write(fname, [parent, '/sourceIndex'], obj.sourceIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/detectorIndex'], obj.detectorIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/wavelengthIndex'], obj.wavelengthIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/dataType'], obj.dataType, 'WriteMode','append');
            hdf5write(fname, [parent, '/dataTypeIndex'], obj.dataTypeIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/sourcePower'], obj.sourcePower, 'WriteMode','append');
            hdf5write(fname, [parent, '/detectorGain'], obj.detectorGain, 'WriteMode','append');
        end

        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.GetWls();
        end
        
        
        % ---------------------------------------------------------
        function idx = GetSourceIndex(obj)
            idx = obj.sourceIndex;
        end
        
        
        % ---------------------------------------------------------
        function idx = GetDetectorIndex(obj)
            idx = obj.detectorIndex;
        end
        
        
        % ---------------------------------------------------------
        function idx = GetWavelengthIndex(obj)
            idx = obj.wavelengthIndex;
        end
        
        
    end
    
end

