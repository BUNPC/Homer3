classdef ProcInputClass < handle
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        CondName2Subj;           % Used by group processing stream
        CondName2Run;            % Used by subject processing stream      
        tIncMan;                 % Manually include/excluded time points
        mlActMan;                   % Manually include/excluded time points
        stimValSettings;         % Derived stim values 
        misc;
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcInputClass(acquired)
            obj.CondName2Subj = [];
            obj.CondName2Run = [];
            obj.tIncMan = {};
            obj.mlActMan = {};
            obj.misc = [];
            obj.stimValSettings = struct('none',0, 'incl',1, 'excl_manual',-1, 'excl_auto',-2);
            if nargin==0
                return;
            end
            obj.GenerateDerivedParams(acquired);
        end
        
        
        % ----------------------------------------------------------------------------------
        function  GenerateDerivedParams(obj, acquired)
            if isempty(acquired)
                return;
            end
            params = acquired.MutableParams();
            for ii=1:length(params)
                eval( sprintf('obj.misc.%s = acquired.Get%s();', params{ii}, params{ii}) );
            end
        end
                
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isempty(obj)
                obj = ProcInputClass();
            end
            obj.CondName2Subj = obj2.CondName2Subj;
            obj.CondName2Run = obj2.CondName2Run;
            obj.tIncMan = obj2.tIncMan;
            
            % misc could contain handle objects, which use the Copy methods to transfer their contents 
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2.misc, ''%s'')', fields{ii}))
                    continue;
                end
                if isa(eval(sprintf('obj.misc.%s', fields{ii})), 'handle')
                    eval( sprintf('obj.misc.%s.Copy(obj2.misc.%s);', fields{ii}, fields{ii}) );
                else
                    eval( sprintf('obj.misc.%s = obj2.misc.%s;', fields{ii}, fields{ii}) );
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b=0;
            if isempty(obj)
                b=1;
                return
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 6;
            end
            fprintf('%sInput:\n', blanks(indent));
            fprintf('%sCondName2Subj:\n', blanks(indent+4));
            pretty_print_matrix(obj.CondName2Subj, indent+4, sprintf('%%d'))
            fprintf('%sCondName2Run:\n', blanks(indent+4));
            pretty_print_matrix(obj.CondName2Run, indent+4, sprintf('%%d'))
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
        function LoadVars(obj, vars)
            if ~isstruct(vars)
                return;
            end
            fields = fieldnames(vars); 
            for ii=1:length(fields) 
                eval( sprintf('obj.misc.%s = vars.%s;', fields{ii}, fields{ii}) );
            end
        end
        
    end
        
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValSettings(obj)
            vals = obj.stimValSettings;
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj)
            s = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val)
            obj.tIncMan = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function tIncMan = GetTincMan(obj)
             tIncMan = obj.tIncMan;
        end
        
                
        % ----------------------------------------------------------------------------------
        function mlActMan = GetMeasListActMan(obj, iDataBlk)
            mlActMan = {};            
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = length(obj.tIncMan);
        end
        
        
    end
    
    
        
end

