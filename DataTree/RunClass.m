classdef RunClass < TreeNodeClass
    
    properties % (Access = private)
        rnum;
        acquired;
    end
    
    methods
                
        % ----------------------------------------------------------------------------------
        function obj = RunClass(varargin)
            %
            % Syntax:
            %   obj = RunClass()
            %   obj = RunClass(filename, iSubj, iRun, rnum);
            %
            % Example 1:
            %   r = RunClass('./s1/neuro_run01.nirs',1,1,1);
            %
            obj@TreeNodeClass(varargin);
            obj.type  = 'run';
            obj.iGroup = 1;
            if nargin==4
                obj.name  = varargin{1};
                obj.iSubj = varargin{2};
                obj.iRun  = varargin{3};
                obj.rnum  = varargin{4};
            elseif nargin==1
                if ischar(varargin{1}) && strcmp(varargin{1},'copy')
                    return;
                end
            elseif nargin==0
                obj.name  = '';
                obj.iSubj = 0;
                obj.iRun  = 0;
                obj.rnum  = 0;
                return;
            else
                return;
            end            

            if obj.IsNirs()
                obj.acquired = NirsClass(obj.name);
            else
                obj.acquired = SnirfClass(obj.name);
            end            
            obj.procStream = ProcStreamClass([], obj.acquired);
            obj.CondName2Group = [];
            obj.Load();
        end

        
            
        % ----------------------------------------------------------------------------------
        function Load(obj)
            obj.acquired.Load();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('options','var')
                options = 'acquired:derived';
            end
            options_s = obj.parseSaveOptions(options);
            
            % Save derived data
            if options_s.derived
                if exist('./groupResults.mat','file')
                    load( './groupResults.mat' );
                    if strcmp(class(group.subjs(obj.iSubj).runs(obj.iRun)), class(obj))
                        group.subjs(obj.iSubj).runs(obj.iRun) = obj;
                    end
                    save( './groupResults.mat','group' );
                end
            end
            
            % Save acquired data
            if options_s.acquired
                obj.acquired.Save();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procResult
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procStream.output = ProcResultClass();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % N2 to N1 if N1 and N2 are same nodes
        % ----------------------------------------------------------------------------------
        function Copy(obj, R)
            if obj == R
                obj.copyProcParamsFieldByField(R);
            end
        end
        
            
        % ----------------------------------------------------------------------------------
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of runs are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            [p1,n1] = fileparts(obj1.name);
            [p2,n2] = fileparts(obj2.name);
            if ~strcmp([p1,'/',n1],[p2,'/',n2])
                B=0;
                return;
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
            
        % ----------------------------------------------------------------------------------
        function b = IsNirs(obj)
            b = false;
            [~,~,ext] = fileparts(obj.name);
            if strcmp(ext,'.nirs')
                b = true;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
                return;
            end
            if obj.procStream.FindVar(varname)==true
                found = true;
                return;
            end            
            if obj.acquired.FindVar(varname)==true
                found = true;
                return;
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname)
            if isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            elseif obj.procStream.FindVar(varname)==true
                varval = obj.procStream.GetVar(varname);
            else
                varval = obj.acquired.GetVar(varname);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Calc(obj)           
            % Recalculating result means deleting old results
            obj.procStream.output.Flush();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find all variables needed by proc stream, find them in this 
            % runs, and load them to proc stream input
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % a) Find all variables needed by proc stream
            args = obj.procStream.GetInputArgs();

            % b) Find these variables in this run
            vars = [];
            for ii=1:length(args)
                if ~obj.FindVar(args{ii})
                    continue;
                end
                eval( sprintf('vars.%s = obj.GetVar(args{ii});', args{ii}) );
            end
            
            % c) Load the needed variables to proc stream input
            obj.procStream.input.LoadVars(vars);

            % Calculate processing stream
            obj.procStream.Calc();
        end

        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 4;
            end
            fprintf('%sRun %d:\n', blanks(indent), obj.iRun);
            fprintf('%sCondNames: %s\n', blanks(indent+4), cell2str(obj.CondNames));
            fprintf('%sCondName2Group:\n', blanks(indent+4));
            pretty_print_matrix(obj.CondName2Group, indent+4, sprintf('%%d'));            
            obj.procStream.input.Print(indent+4);
            obj.procStream.output.Print(indent+4);            
        end
        
    end    % Public methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pubic Set/Get methods for acquired data 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
            
        % ----------------------------------------------------------------------------------
        function t = GetTime(obj, iDataBlk)
            if nargin==1
                iDataBlk=1;
            end
            t = obj.acquired.GetTime(iDataBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function d = GetRawData(obj, iDataBlk)
            if nargin<2
                iDataBlk = 1;
            end
            d = obj.acquired.GetDataMatrix(iDataBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function d = GetDataMatrix(obj, iDataBlk)
            if nargin<2
                iDataBlk = 1;
            end
            d = obj.acquired.GetDataMatrix(iDataBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, iCh] = GetDataBlocksIdxs(obj, iCh)
            if nargin<2
                iCh = [];
            end
            [iDataBlks, iCh] = obj.acquired.GetDataBlocksIdxs(iCh);
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = obj.acquired.GetDataBlocksNum();
        end
       
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj)
            SD.Lambda  = obj.acquired.GetWls();
            SD.SrcPos  = obj.acquired.GetSrcPos();
            SD.DetPos  = obj.acquired.GetDetPos();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ch = GetMeasList(obj, iDataBlk)
            if ~exist('iDataBlk','var') || isempty(iDataBlk)
                iDataBlk=1;
            end
            ch                 = InitMeasLists();
            
            ch.MeasList        = obj.acquired.GetMeasList(iDataBlk);
            ch.MeasListVis     = ones(size(ch.MeasList,1), 1);
            ch.MeasListActMan  = ones(size(ch.MeasList,1),1);
            ch.MeasListActAuto = ones(size(ch.MeasList,1),1);
            ch.MeasListAct     = bitand(ch.MeasListActMan, ch.MeasListActMan);
        end

        
        % ----------------------------------------------------------------------------------
        function SetStims_MatInput(obj,s,t,CondNames)
            obj.acquired.SetStims_MatInput(s,t,CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj)
            % First look in derived data, then acquired
            
            % Proc stream output 
            s = obj.procStream.output.GetStims();
            if isempty(s)
                % Proc stream input
                s = obj.procStream.input.GetStims();
                if isempty(s)
                    % Acquired data
                    s = obj.acquired.GetStims();
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj)
            obj.CondNames = unique(obj.acquired.GetConditions());
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.acquired.GetConditions();
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            s = obj.GetStims();
            for ii=1:size(s,2)
                if ismember(abs(1), s(:,ii))
                    CondNames{ii} = ['-- ', CondNames{ii}];
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetCondName2Group(obj, CondNamesGroup)
            obj.CondName2Group = zeros(1, length(obj.CondNames));
            for ii=1:length(obj.CondNames)
                obj.CondName2Group(ii) = find(strcmp(CondNamesGroup, obj.CondNames{ii}));
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.acquired.GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.acquired.GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAux(obj)
            aux = obj.acquired.GetAux();            
        end
        
        
        % ----------------------------------------------------------------------------------
        function tIncAuto = GetTincAuto(obj)
             tIncAuto = obj.procStream.output.GetTincAuto();
        end
        
        
        % ----------------------------------------------------------------------------------
        function tIncMan = GetTincMan(obj)
             tIncMan = obj.procStream.input.GetTincMan();
        end
        
        
    end        % Public Set/Get methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All other public methods for acquired data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            if isempty(tPts)
                return;
            end
            if isempty(condition)
                return;
            end
            obj.acquired.AddStims(tPts, condition);
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquired.DeleteStims(tPts, condition);
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
            vals     = obj.GetStimValues(icond);
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
        function SetStimValues(obj, icond, vals)
            obj.acquired.SetStimValues(icond, vals);
        end
        
    
        % ----------------------------------------------------------------------------------
        function vals = GetStimValues(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            vals = obj.acquired.GetStimValues(icond);
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
            newname = obj.ErrCheckNewCondName(newname);
            if obj.err ~= 0
                return;
            end
            obj.acquired.RenameCondition(oldname, newname);
        end
        
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValSettings(obj)
            vals = obj.procStream.input.GetStimValSettings();
        end        
        
        
    end

end
