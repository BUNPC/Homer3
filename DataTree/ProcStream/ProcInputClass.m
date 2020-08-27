classdef ProcInputClass < handle
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        errmargin;               % Margin of error used when seeking stims given some time point (default 1e-3)
        tIncMan;                 % Manually included/excluded time points
        mlActMan;                % Manually included/excluded channels
        acquired;                % Modifiable acquisition parameters initally copied from acquisition files
        stimStatus;              % Flag denoting whether stim is enabled or disabled
        stimStatusSettings;      % Values this flag can take
        misc;
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcInputClass(acquired, copyOptions)
            if nargin==1
                copyOptions = '';
            end
            obj.errmargin = 1e-3;
            obj.tIncMan = {};
            obj.mlActMan = {};
            obj.misc = [];
            obj.stimStatusSettings = struct('none',0, 'incl',1, 'excl_manual',-1, 'excl_auto',-2);  % TODO: remove
            if nargin==0
                return;
            end
            if isempty(acquired)
                return;
            end
            obj.acquired = acquired.CopyMutable(copyOptions);
            % Initialize stimStatus matrix based on acq file
            stim = obj.acquired.GetStim();
            obj.stimStatus = {};
            for i = 1:length(stim)
                data = stim(i).GetData();
                if ~isempty(data)
                   obj.stimStatus{i} = [data(:, 1), ones(size(data, 1), 1)]; 
                else
                   obj.stimStatus{i} = []; 
                end
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if ~isa(obj, 'ProcInputClass')
                return;
            end
            if isempty(obj)
                obj = ProcInputClass();
            end
            if ~isempty(obj2.tIncMan)
                obj.tIncMan = obj2.tIncMan;
            end
            
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2.misc, ''%s'')', fields{ii}))
                    continue;
                end
                
                % misc could contain fields that are handle objects. Use
                % CopyHandles instead of plain old assignment statement 
                eval( sprintf('obj.misc.%s = CopyHandles(obj2.misc.%s, obj.misc.%s);', fields{ii}, fields{ii}) );
            end
            if isempty(obj.acquired)
                return;
            end
            obj.acquired.Copy(obj2.acquired);
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
            else
                varval = obj.acquired.GetVar(varname);
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

        
        % ----------------------------------------------------------------------------------        
        function nbytes = MemoryRequired(obj)
            nbytes(1) = sizeof(obj.tIncMan);
            nbytes(2) = sizeof(obj.mlActMan);
            nbytes(3) = sizeof(obj.misc);
            nbytes(4) = sizeof(obj.stimStatusSettings);
            if isempty(obj.acquired)
                nbytes(5) = 0;
            else
                nbytes(5) = obj.acquired.MemoryRequired();
            end
            nbytes = sum(nbytes);
        end

        
        
        % ----------------------------------------------------------------------------------        
        function SaveAcquiredData(obj)
            obj.acquired.SaveMutable();
        end

        
        % ----------------------------------------------------------------------------------
        function b = AcquiredDataModified(obj)
            b = obj.acquired.DataModified();
        end
        
    end
        
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for getting/setting derived parameters 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function vals = GetstimStatusSettings(obj)
            vals = obj.stimStatusSettings;
        end
        
        % ----------------------------------------------------------------------------------
        function status = GetStimStatus(obj, icond)
            if ~exist('icond', 'var')
                status = obj.stimStatus(1);
            end
            if isempty(obj.stimStatus)
                status = [];
                return
            end
            status = obj.stimStatus{icond};
        end
        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val, iBlk)
            if ~exist('iBlk','var')
                iBlk=1;
            end
            obj.tIncMan{iBlk} = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = GetTincMan(obj, iBlk)
            val = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                val = obj.tIncMan{1};
            elseif ~isempty(obj.tIncMan)
                val = obj.tIncMan{iBlk};
            else  % tInc is invalid or unpopulated
                val = [];
            end
        end
       
        
        % ----------------------------------------------------------------------------------
        function ml = GetMeasListActMan(obj, iBlk)
            ml = obj.mlActMan;            
        end

        
        % ----------------------------------------------------------------------------------
        function SetMeasListActMan(obj, ml, iBlk)
            if ~exist('iBlk','var')
                iBlk = 1;
            end
            if isempty(obj.mlActMan)
                obj.mlActMan{iBlk} = ml;
            elseif length(obj.mlActMan) == length(ml)
               obj.mlActMan{iBlk} = ml; 
            end
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
        function s = GetStimStatusTimeSeries(obj, t)
            % Takes array of time points t and returns array the same size
            % valued with stimulus status flags at the nearest time point to
            % their onset
            if nargin==1
                t = [];
            end
            if isempty(obj.stimStatus)
                s = [];
                return
            end
            stim = obj.acquired.GetStim();
            s = zeros(length(t), length(stim));
            for i = 1:length(obj.stimStatus)  % For each stimulus condition in stimStatus
                data = stim(i).GetData();
                status = obj.stimStatus{i};
                if ~isempty(data) && ~isempty(status)
                    for j = 1:length(data(:,1))
                         k = find(abs(t - data(j,1)) < obj.errmargin);
                         s(k, i) = status(j, 2);
                    end            
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function a = GetStimAmplitudeTimeSeries(obj, t)
            if nargin==1
                t = [];
            end
            a = obj.acquired.GetStims(t);
        end
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            if isempty(tPts)
                return;
            end
            if isempty(condition)
                return;
            end
            stim = obj.acquired.GetStim();
            % Need to ensure proper stimStatus order after calls to
            % SortStims in acquired object
            names_pre = {stim.name};
            % Add the stims to the acq files
            obj.acquired.AddStims(tPts, condition);
            stim = obj.acquired.GetStim();
            names_post = {stim.name};
            tmp = obj.stimStatus;
            obj.stimStatus = {};
            % Reorder existing stims
            for i = 1:length(names_post)
                if strcmp(names_post{i}, condition)  % If this is the condition of the added stim
                    j = find(strcmp(condition, names_pre));
                    if ~isempty(j)
                        obj.stimStatus{i} = tmp{j};
                    else
                        obj.stimStatus{i} = [];
                    end
                else
                    for j = 1:length(names_pre)
                        if strcmp(names_post{i}, names_pre{j})
                           obj.stimStatus{i} = tmp{j};
                        end
                    end
                end
            end
            % Init status for new stim
            for i = 1:length(obj.stimStatus)
                if strcmp(condition, stim(i).GetName())
                    obj.stimStatus{i} = [obj.stimStatus{i}; [tPts, ones(length(tPts),1)]];
                    return
                end
            end
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || strcmp(condition, '')
                condition = '';
                stim = obj.acquired.GetStim();
                % Find all stims for any conditions which match the time points and 
                % remove the row
                for i = 1:length(stim)  % For each condition
                    data = stim(i).GetData();
                    if ~isempty(data)
                        k = [];
                        for j=1:length(tPts)  % For each selected time point, search for nearby stims
                            k = [k, find( abs(data(:,1)-tPts(j)) < obj.errmargin )]; %#ok<AGROW>
                        end
                        % Remove stims from stimStatus property too
                        status = obj.stimStatus{i};
                        if ~isempty(status)
                            status(k, :) = [];
                            obj.stimStatus{i} = status; 
                        end
                    end
                end
            end
            obj.acquired.DeleteStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            
            stim = obj.acquired.GetStim();
            
            if ~exist('condition','var') || strcmp(condition, '')
                stim = obj.acquired.GetStim();
                % Find all stims for any conditions which match the time points and 
                % flip it's value.
                for i = 1:length(stim)  % For each condition
                    data = stim(i).GetData();
                    if ~isempty(data)
                        k = [];
                        for j=1:length(tPts)  % For each selected time point, search for nearby stims
                            k = [k, find( abs(data(:,1)-tPts(j)) < obj.errmargin )]; %#ok<AGROW>
                        end
                        % Set stim status to manually excluded
                        status = obj.stimStatus{i};
                        if ~isempty(status)
                            status(k, 2) = -1 * status(k, 2);
                            obj.stimStatus{i} = status; 
                        end
                    end
                end
            else
                warning('Cannot toggle stims for a specific condition.')
                return;
%                 conditions = obj.acquired.GetConditions();
%                 icond = find(strcmp(conditions, condition));
%                 data = stim(icond).GetData();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquired.MoveStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(obj, icond)
            tpts     = obj.GetStimTpts(icond);
            duration = obj.GetStimDuration(icond);
            amps     = obj.GetStimAmplitudes(icond);
        end
        
    
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            obj.acquired.SetStimTpts(icond, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            tpts = obj.acquired.GetStimTpts(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            obj.acquired.SetStimDuration(icond, duration);
        end
        
    
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            duration = obj.acquired.GetStimDuration(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimAmplitudes(obj, icond, amps)
            obj.acquired.SetStimAmplitudes(icond, amps);
        end
        
    
        % ----------------------------------------------------------------------------------
        function amps = GetStimAmplitudes(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            amps = obj.acquired.GetStimAmplitudes(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.acquired.GetConditions();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            obj.acquired.SetConditions(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStims_MatInput(obj, s, t, CondNames)  % Deprecated
            obj.acquired.SetStims_MatInput(s, t);
        end
        
        
        % ----------------------------------------------------------------------------------
        function StimReject(obj, t, ~)
            % TODO implement 3rd argument iBlk
            iBlk = 1;
            for i = 1:length(obj.stimStatus)  % For each stim condition
                enabled = find(obj.stimStatus{i}(:, 2) == 1);
                for j = 1:length(enabled)
                    k = find(abs(t - obj.stimStatus{i}(enabled(j), 1)) < obj.errmargin);
                    if ~obj.tIncMan{iBlk}(k)
                        obj.stimStatus{i}(enabled(j), 2) = -1;
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function StimInclude(obj, t, ~)
            % TODO implement 3rd argument iBlk
            iBlk = 1;
            for i = 1:length(obj.stimStatus)  % For each stim condition
                disabled = find(obj.stimStatus{i}(:, 2) == -1);
                for j = 1:length(disabled)
                    k = find(abs(t - obj.stimStatus{i}(disabled(j), 1)) < obj.errmargin);
                    if obj.tIncMan{iBlk}(k)
                        obj.stimStatus{i}(disabled(j), 2) = 1;
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            % Function to rename a condition. Important to note that changing the
            % condition involves 2 distinct well defined steps:
            %
            %   a) For the current element change the name of the specified (old)
            %      condition ONLY for ALL the ACQUIRED data elements under the
            %      current element, be it run, subj, or group . In this step we DO NOT TOUCH
            %      the derived set of condition names of the run, subject or group .
            %   b) Rebuild condition names and tables of all the tree nodes group, subjects
            %      and runs same as if you were loading during Homer3 startup from the
            %      acquired data.
            %
            % This method only implements step a). 
            %
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            % Reorder stimStatus
            stim = obj.acquired.GetStim();
            names_pre = {stim.name};
            obj.acquired.RenameCondition(oldname, newname);
            stim = obj.acquired.GetStim();
            names_post = {stim.name};
            tmp = obj.stimStatus;
            obj.stimStatus = {};
            for i = 1:length(names_post)
               if strcmp(names_post{i}, newname)
                   j = find(strcmp(oldname, names_pre));
                   obj.stimStatus{i} = tmp{j};
               else
                   for j = 1:length(names_pre)
                        if strcmp(names_post{i}, names_pre{j})
                           obj.stimStatus{i} = tmp{j};
                        end
                   end
               end
            end
        end
    end   
end

