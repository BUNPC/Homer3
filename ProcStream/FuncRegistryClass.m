classdef FuncRegistryClass < matlab.mixin.Copyable

    properties
        p1
        p2
        p3
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegistryClass()
            obj.p1 = [];
            obj.p2 = [];
            obj.p3 = [];
        end
                
        
        % ----------------------------------------------------------------------------------
        function f1(obj)
        end
        
        % ----------------------------------------------------------------------------------
        function f2(obj)
        end
        
        % ----------------------------------------------------------------------------------
        function f3(obj)
        end
        
    end
    
end
