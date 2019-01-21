classdef ProcInputClass < matlab.mixin.Copyable
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        func;       % Processing stream functions
        param;      % Processing stream user-settable input arguments and their current values
        CondName2Subj;  % Used by group processing stream
        CondName2Run;   % Used by subject processing stream      
        tIncMan;        % Manually include/excluded time points
        misc;
        changeFlag;     % Flag specifying if procInput+acquisition data is out 
                        %    of sync with procResult (currently not implemented)
    end
    
    
    methods
        
        % --------------------------------------------------
        function obj = ProcInputClass()
            obj.param = struct([]);
            obj.func = struct([]);
            obj.CondName2Subj = [];
            obj.CondName2Run = [];            
            obj.tIncMan = [];
            obj.misc = [];
            obj.changeFlag = 0;
        end
                
        
        % --------------------------------------------------
        function Copy(obj, obj2)
            if isproperty(obj2, 'param')
                obj.param = copyStructFieldByField(obj.param, obj2.param);
            end
            if isproperty(obj2, 'func')
                obj.func = obj2.func;
            end
            if isproperty(obj2, 'changeFlag')
                obj.changeFlag = obj2.changeFlag;
            end
        end
        
        
        % --------------------------------------------------
        function b = isempty(obj)
            b = true;
            if isempty(obj.func)
                return
            end
            if isempty(obj.func(1).funcName)
                return;
            end
            b = false;
        end        
    end
    
end