classdef ProcInputClass < handle
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        CondName2Subj;           % Used by group processing stream
        CondName2Run;            % Used by subject processing stream      
        tIncMan;                 % Manually include/excluded time points
        mlActMan;                % Manually include/excluded time points
        acquiredEditable;        % Copy of acquisition parameters that are editable 
                                 % through manual GUI operations. 
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
            obj.acquiredEditable = GenericAcqClass();
            if nargin==0
                return;
            end
            if isempty(acquired)
                return;
            end
            obj.acquiredEditable = acquired.CopyMutable();
        end
        
                
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if ~isa(obj, 'ProcInputClass')
                return;
            end
            if isempty(obj)
                obj = ProcInputClass();
            end
            obj.CondName2Subj = obj2.CondName2Subj;
            obj.CondName2Run = obj2.CondName2Run;
            obj.tIncMan = obj2.tIncMan;
            
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2.misc, ''%s'')', fields{ii}))
                    continue;
                end
                
                % misc could contain fields that are handle objects. Use
                % CopyHandles instead of plain old assignment statement 
                eval( sprintf('obj.misc.%s = CopyHandles(obj2.misc.%s, obj.misc.%s);', fields{ii}, fields{ii}) );
            end
            obj.acquiredEditable = CopyHandles(obj2.acquiredEditable, obj.acquiredEditable);
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
        function varval = GetVar(obj, varname, iBlk)
            varval = [];
            if exist('iBlk','var') && isempty(iBlk)
                iBlk=1;
            end
            if isproperty(obj, varname)
                eval(sprintf('varval = obj.%s;', varname));
            elseif isproperty(obj.misc, varname)
                eval(sprintf('varval = obj.misc.%s;', varname));
            elseif isproperty(obj.acquiredEditable, varname)
                eval(sprintf('varval = obj.acquiredEditable.%s;', varname));
            end            
            if ~isempty(varval) && exist('iBlk','var')
                if iscell(varval)
                    varval = varval{iBlk};
                else
                    varval = varval(iBlk);
                end
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
        
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for getting/setting derived parameters 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValSettings(obj)
            vals = obj.stimValSettings;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val)
            obj.tIncMan = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function tIncMan = GetTincMan(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk=1;
            end
            
            % TBD: need to implement this
            tIncMan = obj.tIncMan;
        end
        
                
        % ----------------------------------------------------------------------------------
        function mlActMan = GetMeasListActMan(obj, iBlk)
            mlActMan = {};            
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = length(obj.tIncMan);
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for getting/setting editable acquisition parameters such as
    % stimulus and source/detector geometry
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj, t)
            if nargin==1
                t = [];
            end
            s = obj.acquiredEditable.GetStims(t);
        end
        
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            if isempty(tPts)
                return;
            end
            if isempty(condition)
                return;
            end
            obj.acquiredEditable.AddStims(tPts, condition);
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquiredEditable.DeleteStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquiredEditable.MoveStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(obj, icond)
            tpts     = obj.GetStimTpts(icond);
            duration = obj.GetStimDuration(icond);
            vals     = obj.GetStimValues(icond);
        end
        
    
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            obj.acquiredEditable.SetStimTpts(icond, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            tpts = obj.acquiredEditable.GetStimTpts(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            obj.acquiredEditable.SetStimDuration(icond, duration);
        end
        
    
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            duration = obj.acquiredEditable.GetStimDuration(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimValues(obj, icond, vals)
            obj.acquiredEditable.SetStimValues(icond, vals);
        end
        
    
        % ----------------------------------------------------------------------------------
        function vals = GetStimValues(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            vals = obj.acquiredEditable.GetStimValues(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.acquiredEditable.GetConditions();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            obj.acquiredEditable.SetConditions(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            % Function to rename a condition. Important to remeber that changing the
            % condition involves 2 distinct well defined steps:
            %   a) For the current element change the name of the specified (old)
            %      condition for ONLY for ALL the acquired data elements under the
            %      currElem, be it run, subj, or group. In this step we DO NOT TOUCH
            %      the condition names of the run, subject or group.
            %   b) Rebuild condition names and tables of all the tree nodes group, subjects
            %      and runs same as if you were loading during Homer3 startup from the
            %      acquired data.
            %
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            obj.acquiredEditable.RenameCondition(oldname, newname);
        end
    end   
    
end

