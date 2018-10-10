classdef MeasListClass  < matlab.mixin.Copyable
    
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
                obj.sourceIndex      = 1;
                obj.detectorIndex    = 1;
                obj.wavelengthIndex  = 1;
            end
        end
        
        
        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            if ~exist(fname, 'file')
                return;
            end
              
            obj.sourceIndex = hdf5read(fname, [parent, '/sourceIndex']);
            obj.detectorIndex = hdf5read(fname, [parent, '/detectorIndex']);
            obj.wavelengthIndex = hdf5read(fname, [parent, '/wavelengthIndex']);
            obj.dataType = hdf5read(fname, [parent, '/dataType']);
            obj.dataTypeIndex = hdf5read(fname, [parent, '/dataTypeIndex']);
            obj.sourcePower = hdf5read(fname, [parent, '/sourcePower']);
            obj.detectorGain = hdf5read(fname, [parent, '/detectorGain']);

        end

        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
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
        
    end
    
end

