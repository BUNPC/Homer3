classdef DebugLevel
    properties
        possibleValues
        value
    end
                
    methods

        % ----------------------------------------------------------------------------------
        function obj = DebugLevel(value) %#ok<*INUSD>
            obj.possibleValues = struct('none',0,'simulateBadData',1);            
            switch(lower(value))
                case 'none'
                    obj.value = obj.possibleValues.none;
                case 'simulatebaddata'
                    obj.value = obj.possibleValues.simulateBadData;
                otherwise
                    obj.value = obj.possibleValues.none;                    
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function value = Get(obj) 
            value = obj.value;
        end
        
        
        % ----------------------------------------------------------------------------------
        function value = SimulateBadData(obj) 
            value = obj.possibleValues.simulateBadData;
        end
        
        % ----------------------------------------------------------------------------------
        function value = None(obj) 
            value = obj.possibleValues.None;
        end
        
    end
end