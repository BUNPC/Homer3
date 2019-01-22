classdef ProcStreamClass
    
    properties
        input
        output
    end
    
    methods
        
        % ---------------------------------------------------------
        function obj = ProcStreamClass()
            obj.input = ProcInputClass();
            obj.output = ProcResultClass();
        end
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and output) from
        % obj2 to obj
        % ----------------------------------------------------------------------------------
        function copyProcParamsFieldByField(obj, obj2)
            % input
            if isproperty(obj2,'input') && ~isempty(obj2.input)
                if isproperty(obj2.input,'func') && ~isempty(obj2.input.func)
                    obj.input.Copy(obj2.input);
                else
                    [obj.input.func, obj.input.param] = procStreamDefault(obj.type);
                end
            end
            
            % output
            if isproperty(obj2,'output') && ~isempty(obj2.output)
                obj.output = copyStructFieldByField(obj.output, obj2.output);
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = EditProcParam(obj, iFunc, iParam, val)
            if isempty(iFunc)
                return;
            end
            if isempty(iParam)
                return;
            end
            obj.input.func(iFunc).paramVal{iParam} = val;
            eval( sprintf('obj.input.param.%s_%s = val;', ...
                          obj.input.func(iFunc).name, ...
                          obj.input.func(iFunc).param{iParam}) );
            str = sprintf(obj.input.func(iFunc).paramFormat{iParam}, val);
        end
        
    end
    
end