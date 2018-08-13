classdef SDClass  < matlab.mixin.Copyable
    
    properties
        Lambda
        LambdaEmission
        SrcPos
        DetPos
        Frequency
        TimeDelay
        TimeDelayWidth
        MomentOrder
        CorrelationTimeDelay
        CorrelationTimeDelayWidth
        SrcLabels
        DetLabels
    end
    
    
    methods
        
        function obj = SDClass(SD)
            
            if nargin>0
                obj.Lambda          = SD.Lambda;
                obj.LambdaEmission  = [];
                obj.SrcPos  = SD.SrcPos;
                obj.DetPos  = SD.DetPos;
                obj.Frequency  = 1;
                obj.TimeDelay  = 0;
                obj.TimeDelayWidth  = 0;
                obj.MomentOrder = [];
                obj.CorrelationTimeDelay = 0;
                obj.CorrelationTimeDelayWidth = 0;
                for ii=1:size(SD.SrcPos)
                    obj.SrcLabels{ii} = ['S',num2str(ii)];
                end
                for ii=1:size(SD.DetPos)
                    obj.DetLabels{ii} = ['D',num2str(ii)];
                end
            else
                obj.Lambda          = [];
                obj.LambdaEmission  = [];
                obj.SrcPos  = [];
                obj.DetPos  = [];
                obj.Frequency  = 1;
                obj.TimeDelay  = 0;
                obj.TimeDelayWidth  = 0;
                obj.MomentOrder = [];
                obj.CorrelationTimeDelay = 0;
                obj.CorrelationTimeDelayWidth = 0;
                obj.SrcLabels = {};
                obj.DetLabels = {};
            end

        end
        
        
    end
    
end