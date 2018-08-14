classdef SdClass  < matlab.mixin.Copyable
    
    properties
        lambda
        lambdaEmission
        srcPos
        detPos
        frequency
        timeDelay
        timeDelayWidth
        momentOrder
        correlationTimeDelay
        correlationTimeDelayWidth
        srcLabels
        detLabels
    end
    
    
    methods
        
        function obj = SdClass(SD)
            
            if nargin>0
                obj.lambda = SD.Lambda;
                obj.lambdaEmission  = [];
                obj.srcPos  = SD.SrcPos;
                obj.detPos  = SD.DetPos;
                obj.frequency  = 1;
                obj.timeDelay  = 0;
                obj.timeDelayWidth  = 0;
                obj.momentOrder = [];
                obj.correlationTimeDelay = 0;
                obj.correlationTimeDelayWidth = 0;
                for ii=1:size(SD.SrcPos)
                    obj.srcLabels{ii} = ['S',num2str(ii)];
                end
                for ii=1:size(SD.DetPos)
                    obj.detLabels{ii} = ['D',num2str(ii)];
                end
            else
                obj.lambda          = [];
                obj.lambdaEmission  = [];
                obj.srcPos  = [];
                obj.detPos  = [];
                obj.frequency  = 1;
                obj.timeDelay  = 0;
                obj.timeDelayWidth  = 0;
                obj.momentOrder = [];
                obj.correlationTimeDelay = 0;
                obj.correlationTimeDelayWidth = 0;
                obj.srcLabels = {};
                obj.detLabels = {};
            end

        end
        
        
    end
    
end
