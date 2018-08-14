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
        
        
    end
    
end

