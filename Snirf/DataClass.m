classdef DataClass  < matlab.mixin.Copyable
    
    properties
        d
        t
        ml
    end
    
    
    methods
        
        function obj = DataClass(d, t, ml)

            obj.ml = MeasListClass();

            if nargin>0
                obj.d = d;
                obj.t = t;
                for ii=1:size(ml)
                    obj.ml(ii) = MeasListClass(ml(ii,:));
                end
            else
                obj.d = double([]);
                obj.t = double([]);
            end

        end
        
    end
    
end