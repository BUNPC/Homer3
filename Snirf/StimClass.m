classdef StimClass  < matlab.mixin.Copyable
    
    properties
        Name
        Data
    end
    
    methods
        
        function obj = StimClass(s)
            obj.Name = '';
            if nargin>0
                obj.Data = s;
            else
                obj.Data = [];
            end
        end
        
    end
    
end