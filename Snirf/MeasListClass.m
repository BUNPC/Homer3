classdef MeasListClass  < matlab.mixin.Copyable
    
    properties
        SourceIndex
        DetectorIndex
        WavelengthIndex
        DataType
        DataTypeIndex
        SourcePower
        SourcePowerUnit 
        DetectorGain
    end
    

    methods

        function obj = MeasListClass(ml)
            obj.DataType         = 1;
            obj.DataTypeIndex    = 1;
            obj.SourcePower      = 0;
            obj.SourcePowerUnit  = '';
            obj.DetectorGain     = 0;

            if nargin>0
                obj.SourceIndex      = ml(1);
                obj.DetectorIndex    = ml(2);
                obj.WavelengthIndex  = ml(4);
            else
                obj.SourceIndex      = 1;
                obj.DetectorIndex    = 1;
                obj.WavelengthIndex  = 1;
            end
        end
        
        
    end
    
end