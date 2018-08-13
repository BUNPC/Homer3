classdef AuxClass  < matlab.mixin.Copyable
    
    properties
        Name
        d
        t
    end
    
    methods
        
        function obj = AuxClass(aux)
            obj.Name = '';
            if nargin>0
                obj.d = aux;
                obj.t = [];
            else
                obj.d = [];
                obj.t = [];
            end
        end
        
    end
    
end