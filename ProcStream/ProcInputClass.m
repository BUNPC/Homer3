classdef ProcInputClass < matlab.mixin.Copyable
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        procFunc;       % Processing stream functions
        procParam;      % Processing stream user-settable input arguments and their current values
        CondName2Subj;  % Used by group processing stream
        CondName2Run;   % Used by subject processing stream      
        tIncMan;        % Manually include/excluded time points
        changeFlag;     % Flag specifying if procInput+acquisition data is out 
                        %    of sync with procResult (currently not implemented)
    end
    
    
    methods
        
        % --------------------------------------------------
        function obj = ProcInputClass()
            obj.procParam = struct([]);
            obj.procFunc = struct([]);
            obj.CondName2Subj = [];
            obj.CondName2Run = [];            
            obj.tIncMan = [];
            obj.changeFlag = 0;
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
        end
        
        
        % --------------------------------------------------
        function b = isempty(obj)
            b = true;
            if isempty(obj.procFunc)
                return
            end
            if isempty(obj.procFunc(1).funcName)
                return;
            end
            b = false;
        end        
    end
    
end