classdef FuncCallClass < handle
    properties
        name
        nameUI
        argOut
        argIn
        paramIn
        help
    end
    
    methods
        
        % ------------------------------------------------------------
        function obj = FuncCallClass()
            obj.name        = '';
            obj.nameUI      = '';
            obj.argOut      = '';
            obj.argIn       = '';
            obj.paramIn     = ParamClass().empty;
            obj.help        = '';
        end

        
        % ------------------------------------------------------------
        function obj = GetHelp(obj)
            fhelp = FuncHelpClass(obj.name);
            obj.help = fhelp.GetDescr();
        end
        
        
        % ------------------------------------------------------------
        function GetParamHelp(obj, key)
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            fhelp = FuncHelpClass(obj.name);
            obj.paramIn(idx).help = fhelp.GetParamDescr(obj.paramIn(idx).name);
        end
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
        % ------------------------------------------------------------
        function idx = GetParamIdx(obj, key)
            idx = [];
            if ~exist('key','var') || isempty(key)
                key=1;
            end
            if ischar(key)
                for ii=1:length(obj.paramIn)
                    if strcmp(key, obj.paramIn(ii).name)
                        idx=ii;
                        break;
                    end
                end
            elseif iswholenum(key) && (key <= length(obj.paramIn))
                idx = key;
            end
        end
        
        
    end
end

