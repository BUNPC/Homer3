classdef StimClass  < matlab.mixin.Copyable
    
    properties
        name
        data
    end
    
    methods
        
        function obj = StimClass(s)
            obj.name = '';
            if nargin>0
                obj.data = s;
            else
                obj.data = [];
            end
        end
        
    end
    
end