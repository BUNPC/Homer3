classdef AuxClass  < matlab.mixin.Copyable
    
    properties
        name
        d
        t
    end
    
    methods
        
        function obj = AuxClass(aux)
            obj.name = '';
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