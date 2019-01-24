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
        
        % ----------------------------------------------------------------------------------
        function obj = ProcInputClass()
            obj.param = struct([]);
            obj.func = struct([]);
            obj.CondName2Subj = [];
            obj.CondName2Run = [];            
            obj.tIncMan = [];
            obj.misc = [];
            obj.changeFlag = 0;
        end
                
        
        % ----------------------------------------------------------------------------------
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
        
        
        % ----------------------------------------------------------------------------------
        function b = isempty(obj)
            b = true;
            if isempty(obj.func)
                return
            end
            if isempty(obj.func(1).name)
                return;
            end
            b = false;
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = EditParam(obj, iFunc, iParam, val)
            str = '';
            if isempty(iFunc)
                return;
            end
            if isempty(iParam)
                return;
            end
            obj.func(iFunc).paramVal{iParam} = val;
            eval( sprintf('obj.param.%s_%s = val;', ...
                          obj.func(iFunc).name, ...
                          obj.func(iFunc).param{iParam}) );
            str = sprintf(obj.func(iFunc).paramFormat{iParam}, val);
        end

        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)            
            b=0;           
            if isempty(obj.func)
                b=1;
                return;
            end
            
            % Now that we know we have a non-empty func, check to see if at least
            % one VALID function is present
            b=1;
            for ii=1:length(obj.func)
                if ~isempty(obj.func(ii).name) && ~isempty(obj.func(ii).argOut)
                    b=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function args = InputArgs2Cell(obj, iFunc)
            args={};
            if isempty(obj.func)
                return;
            end
            if ~exist('iFunc', 'var') || isempty(iFunc)
                iFunc = 1:length(obj.func);
            end
            nFunc = length(obj.func);

            kk=1;
            for jj=1:length(iFunc)
                if iFunc(jj)>nFunc
                    continue;
                end
                if obj.func(iFunc(jj)).argIn(1) ~= '('
                    continue;
                end
                j=2;
                k = [findstr(obj.func(iFunc(jj)).argIn,',') length(obj.func(iFunc(jj)).argIn)+1];
                for ii=1:length(k)
                    args{kk} = obj.func(iFunc(jj)).argIn(j:k(ii)-1);
                    j = k(ii)+1;
                    kk=kk+1;
                end
            end
            args = unique(args, 'stable');
        end
        
        
        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
            elseif isproperty(obj.misc, varname)
                found = true;
            end
        end

        
        % ----------------------------------------------------------------------------------
        function var = GetVar(obj, varname)
            var = [];
            if isproperty(obj, varname)
                eval(sprintf('var = obj.%s;', varname));
            elseif isproperty(obj.misc, varname)
                eval(sprintf('var = obj.misc.%s;', varname));
            end
        end

        
        % ----------------------------------------------------------------------------------
        function [sargin, p] = ParseInputParams(obj, iFunc)
            sargin = '';
            p = [];

            if isempty(obj.func)
                return;
            end
            if iFunc>length(obj.func)
                return;
            end
            
            sarginVal = '';
            for iP = 1:obj.func(iFunc).nParam
                if ~obj.func(iFunc).nParamVar
                    p{iP} = obj.func(iFunc).paramVal{iP};
                else
                    p{iP}.name = obj.func(iFunc).param{iP};
                    p{iP}.val = obj.func(iFunc).paramVal{iP};
                end
                if length(obj.func(iFunc).argIn)==1 & iP==1
                    sargin = sprintf('%sp{%d}', sargin, iP);
                    if isnumeric(p{iP})
                        if length(p{iP})==1
                            sarginVal = sprintf('%s%s', sarginVal, num2str(p{iP}));
                        else
                            sarginVal = sprintf('%s[%s]', sarginVal, num2str(p{iP}));
                        end
                    elseif ~isstruct(p{iP})
                        sarginVal = sprintf('%s,%s', sarginVal, p{iP});
                    else
                        sarginVal = sprintf('%s,[XXX]', sarginVal);
                    end
                else
                    sargin = sprintf('%s,p{%d}', sargin, iP);
                    if isnumeric(p{iP})
                        if length(p{iP})==1
                            sarginVal = sprintf('%s,%s', sarginVal, num2str(p{iP}));
                        else
                            sarginVal = sprintf('%s,[%s]', sarginVal, num2str(p{iP}));
                        end
                    elseif ~isstruct(p{iP})
                        sarginVal = sprintf('%s,%s', sarginVal, p{iP});
                    else
                        sarginVal = sprintf('%s,[XXX]',sarginVal);
                    end
                end
            end
        end     
        
        
        % ----------------------------------------------------------------------------------
        function sargout = ParseOutputArgs(obj, iFunc)
            sargout = '';
            if isempty(obj.func)
                return;
            end
            if iFunc>length(obj.func)
                return;
            end            
            sargout = obj.func(iFunc).argOut;
            for ii=1:length(obj.func(iFunc).argOut)
                if sargout(ii)=='#'
                    sargout(ii) = ' ';
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFuncName(obj, iFunc)
            name = '';
            if isempty(obj.func)
                return;                
            end
            if iFunc>length(obj.func)
                return;
            end
            name = obj.func(iFunc).name;
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFuncNamePrettyPrint(obj, iFunc)
            name = '';
            if isempty(obj.func)
                return;                
            end
            if iFunc>length(obj.func)
                return;
            end
            k = find(obj.func(iFunc).name=='_');
            if isempty(k)
                name = obj.func(iFunc).name;
            else
                name = sprintf('%s\\%s...', obj.func(iFunc).name(1:k-1), obj.func(iFunc).name(k:end));
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetFuncNum(obj)
            n = length(obj.func);
        end

                
        % ----------------------------------------------------------------------------------
        function LoadVars(obj, vars)
            if ~isstruct(vars)
                return;
            end
            fields = fieldnames(vars); 
            for ii=1:length(fields) 
                eval( sprintf('obj.misc.%s = vars.%s;', fields{ii}, fields{ii}) );
            end
        end

        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val)
            obj.tIncMan = val;
        end
                
        % ----------------------------------------------------------------------------------
        function val = GetTincMan(obj)
             val = obj.tIncMan;
        end
        
        
        
        
    end
    
end