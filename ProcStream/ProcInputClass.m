classdef ProcInputClass < handle
    
    properties
        procParam;
        procFunc;
        changeFlag;
        conversionFlag;
    end
    
    
    methods
        
        % --------------------------------------------------
        function obj = ProcInputClass()
            obj.procParam = struct([]);
            obj.procFunc = struct([]);
            obj.changeFlag = 0;
            obj.conversionFlag = 0;
        end
        
        
        % --------------------------------------------------
        function Copy(obj, obj2)
            if isproperty(obj2, 'procParam')
                obj.procParam = copyStructFieldByField(obj.procParam, obj2.procParam);
            end
            if isproperty(obj2, 'procFunc')
                obj.procFunc = obj2.procFunc;
            end
            if isproperty(obj2, 'changeFlag')
                obj.changeFlag = obj2.changeFlag;
            end
            if isproperty(obj2, 'conversionFlag')
                obj.conversionFlag = obj2.conversionFlag;
            end
        end
        
    end
    
end