classdef SubjClass < TreeNodeClass
    
    properties % (Access = private)
        runs;
    end
       
    
    methods
                
        % ----------------------------------------------------------------------------------
        function obj = SubjClass(varargin)
            obj@TreeNodeClass(varargin);
            
            obj.type  = 'subj';
            obj.runs = RunClass().empty;
            if nargin==0
                obj.name  = '';
                return;
            end
            
            if nargin<3
                if isa(varargin{1}, 'SubjClass')
                    if nargin==1
                        obj.Copy(varargin{1});
                    elseif nargin==2
                        obj.Copy(varargin{1}, varargin{2});
                    end
                    return;
                elseif isa(varargin{1}, 'FileClass')
                    [~, obj.name] = varargin{1}.ExtractNames();
                else
                    obj.name = varargin{1};
                end
            elseif nargin==3
                if ~isa(varargin{1}, 'FileClass')
                    [~, obj.name] = varargin{1}.ExtractNames();
                else
                    obj.name = varargin{1};
                end
                obj.iGroup = varargin{2};
                obj.iSubj = varargin{3};
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            for ii = 1:length(obj.runs)
                nbytes = nbytes + obj.runs(ii).MemoryRequired();
            end
            nbytes = nbytes + obj.procStream.MemoryRequired();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % S to obj if obj and S are equivalent nodes
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, conditional)
            % Copy SubjClass object obj2 to SubjClass object obj. Conditional option applies 
            % only to all the runs under this group. If == 'conditional' ONLY derived data, 
            % that is, only from procStream but NOT from acquired data is copied for all the runs. 
            % 
            % Conversly unconditional copy copies all properties in the runs under this subject
            if nargin==3 && strcmp(conditional, 'conditional')
                if obj.Mismatch(obj2)
                    return
                end
                for i = 1:length(obj.runs)
                    j = obj.existRun(i,obj2);
                    if (j>0)
                        obj.runs(i).Copy(obj2.runs(j), 'conditional');
                    elseif i<=length(obj2.runs)
                        obj.runs(i).Copy(obj2.runs(i), 'conditional');
                    else
                        obj.Mismatch();
                    end
                end
                obj.Copy@TreeNodeClass(obj2, 'conditional');
            else
                if nargin<3
                    conditional = '';
                end
                for i=1:length(obj2.runs)
                    obj.runs(i) = RunClass(obj2.runs(i), conditional);
                end
                obj.Copy@TreeNodeClass(obj2);
            end
        end
        
        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            obj.CondNames = obj2.CondNames;
            for ii = 1:length(obj.runs)
                obj.runs(ii).CopyStims(obj2.runs(ii));
            end
        end
               
        
        % ----------------------------------------------------------------------------------
        % Check whether run R exists in this subject and return
        % its index if it does exist. Else return 0.
        % ----------------------------------------------------------------------------------
        function j = existRun(obj, k, S)
            j=0;
            for i=1:length(S.runs)
                [~,rname1] = fileparts(obj.runs(k).name);
                [~,rname2] = fileparts(S.runs(i).name);
                if strcmp(rname1,rname2)
                    j=i;
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of runs are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            if ~strcmp(obj1.name, obj2.name)
                B=0;
                return;
            end
            for i=1:length(obj1.runs)
                j = existRun(obj1, i, obj2);
                if j==0
                    B=0;
                    return;
                end
            end
            for i=1:length(obj2.runs)
                j = existRun(obj2, i, obj1);
                if j==0
                    B=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = CheckForNameConflict(obj, run)
            b = false;
            [~, runname] = fileparts(run.GetName());
            if strcmp(runname, obj.name)
                b = true;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Add(obj, run)
            [~,f,e] = fileparts(run.GetName());
            if strcmp(f, obj.name)
                msg{1} = sprintf('WARNING: The run being added (%s) has the same name as the subject (%s) containing it. ', [f,e], obj.name);
                msg{2} = sprintf('The run names should not have the same name as the subject, otherwise '); 
                msg{3} = sprintf('it may cause incorrect results in processing. Do you want to change this run''s name?');
                obj.logger.Write(sprintf('%s\n', [msg{:}]));

                % Deconflict name of subject with name of run if there is no
                % subject folder for this subject
                if ~ispathvalid(['./',obj.name], 'dir')
                    obj.name = [obj.name, '_s'];
                    obj.logger.Write(sprintf('Renaming subject to %s\n', obj.name));
                end
            end
            
            
            % Add run to this subject
            jj=0;
            for ii=1:length(obj.runs)
                if strcmp(obj.runs(ii).GetName, run.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.runs)+1;
                run.SetIndexID(obj.iGroup, obj.iSubj, jj);
                run.SetPath(obj.path);                      % Inherit root path from subject
                obj.runs(jj) = run;
                obj.logger.Write(sprintf('     Added run %s to subject %s.\n', obj.runs(jj).GetFileName, obj.GetName));
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function list = DepthFirstTraversalList(obj)
            list{1} = obj;
            for ii=1:length(obj.runs)
                list{ii+1,1} = obj.runs(ii);
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procResult
        % ----------------------------------------------------------------------------------
        function Reset(obj, option)
            if ~exist('option','var')
                option = 'down';
            end
            if strcmp(option, 'down')
                for jj = 1:length(obj.runs)
                    obj.runs(jj).Reset();
                end
            end
            Reset@TreeNodeClass(obj);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = LoadSubBranch(obj)
            err = -1;
            if isempty(obj)
                return;
            end
            err1 = obj.procStream.Load([obj.path, obj.GetOutputFilename()]);
            err2 = obj.runs(1).Load();
            if err1==0 && err2==0
                err = 0;
            end
        end            

        
        % ----------------------------------------------------------------------------------
        function FreeMemorySubBranch(obj)
            if isempty(obj)
                return;
            end
            obj.runs(1).FreeMemory()
        end            
            
        
        % ----------------------------------------------------------------------------------
        function CreateOutputDir(obj)
            if ispathvalid([obj.pathOutputAlt, obj.outputDirname, obj.name])
                return;
            end
            if ~ispathvalid([obj.pathOutputAlt, obj.name])
                return;
            end
            mkdir([obj.pathOutputAlt, obj.outputDirname, obj.name]);
        end
            

        
        % ----------------------------------------------------------------------------------
        function LoadVars(obj, r, tHRF_common)
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all runs. Use smallest tHRF as the common one.
            r.procStream.output.SettHRFCommon(tHRF_common, r.name, r.type);
            
            obj.outputVars.dodAvgRuns{r.iRun}    = r.procStream.output.GetVar('dodAvg');
            obj.outputVars.dodAvgStdRuns{r.iRun} = r.procStream.output.GetVar('dodAvgStd');
            obj.outputVars.dodSum2Runs{r.iRun}   = r.procStream.output.GetVar('dodSum2');
            obj.outputVars.dcAvgRuns{r.iRun}     = r.procStream.output.GetVar('dcAvg');
            obj.outputVars.dcAvgStdRuns{r.iRun}  = r.procStream.output.GetVar('dcAvgStd');
            obj.outputVars.dcSum2Runs{r.iRun}    = r.procStream.output.GetVar('dcSum2');
            obj.outputVars.tHRFRuns{r.iRun}      = r.procStream.output.GetTHRF();
            obj.outputVars.mlActRuns{r.iRun}     = r.procStream.output.GetVar('mlActAuto');
            obj.outputVars.nTrialsRuns{r.iRun}   = r.procStream.output.GetVar('nTrials');
            if ~isempty(r.procStream.output.GetVar('misc'))
                if isfield(r.procStream.output.misc, 'stim') == 1
                    obj.outputVars.stimRuns{r.iRun}      = r.procStream.output.misc.stim;
                else
                    obj.outputVars.stimRuns{r.iRun}      = r.GetVar('stim');
                end
            else
                obj.outputVars.stimRuns{r.iRun}      = r.GetVar('stim');
            end
            obj.outputVars.dcRuns{r.iRun}       = r.procStream.output.GetVar('dc');
            obj.outputVars.AauxRuns{r.iRun}      = r.procStream.output.GetVar('Aaux');
            obj.outputVars.tIncAutoRuns{r.iRun}  = r.procStream.output.GetVar('tIncAuto');
            obj.outputVars.rcMapRuns{r.iRun}     = r.procStream.output.GetVar('rcMap');

            
            
            % a) Find all variables needed by proc stream
            args = obj.procStream.GetInputArgs();

            % b) Find these variables in this run
            for ii = 1:length(args)
                if ~eval( sprintf('isproperty(obj.outputVars, ''%s'')', args{ii}) )
                    eval( sprintf('obj.outputVars.%s = obj.GetVar(args{ii});', args{ii}) );
                end
            end
            
            % Free run memory 
            r.FreeMemory()
        end
            
                   
            
        % ----------------------------------------------------------------------------------
        function Calc(obj, options)
            if ~exist('options','var') || isempty(options)
                options = 'overwrite';
            end
            
            if strcmpi(options, 'overwrite')
                % Recalculating result means deleting old results, if
                % option == 'overwrite'
                obj.procStream.output.Flush();
            end
                        
            if obj.DEBUG
                obj.logger.Write(sprintf('Calculating processing stream for group %d, subject %d\n', obj.iGroup, obj.iSubj));
            end
            
            % Calculate all runs in this session and generate common tHRF
            r = obj.runs;
            tHRF_common = {};
            for iRun = 1:length(r)
                r(iRun).Calc();

                % Find smallest tHRF among the subjects and make this the common one.
                tHRF_common = r(iRun).procStream.output.GeneratetHRFCommon(tHRF_common);
            end
            
            
            % Load all the variables that might be needed by procStream.Calc() to calculate proc stream for this subject
            for iRun = 1:length(r)
                obj.LoadVars(r(iRun), tHRF_common);
            end
                        
            Calc@TreeNodeClass(obj);

            if obj.DEBUG
                fprintf('Completed processing stream for group %d, subject %d\n', obj.iGroup, obj.iSubj);
                fprintf('\n');
            end
            
            % Update call application GUI using it's generic Update function 
            if ~isempty(obj.updateParentGui)
                obj.updateParentGui('DataTreeClass', [obj.iGroup, obj.iSubj, obj.iRun]);
            end
            
        end
                
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 4;
            else
                indent = indent+4;
            end
            Print@TreeNodeClass(obj, indent);
            for ii=1:length(obj.runs)
                obj.runs(ii).Print(indent);
            end
        end
        

        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            for ii = 1:length(obj.runs)
                if ~obj.runs(ii).IsEmpty()
                    b = false;
                    break;
                end
            end
        end


        % ----------------------------------------------------------------------------------
        function b = IsEmptyOutput(obj)
            b = true;
            if isempty(obj)
                return;
            end
            for ii = 1:length(obj.runs)
                if ~obj.runs(ii).IsEmptyOutput()
                    b = false;
                    break;
                end
            end
        end


        % ----------------------------------------------------------------------------------
        function SaveAcquiredData(obj)            
            for ii = 1:length(obj.runs)
                obj.runs(ii).SaveAcquiredData();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = AcquiredDataModified(obj)
            b = false;
            for ii = 1:length(obj.runs)
                if obj.runs(ii).AcquiredDataModified()
                    b = true;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname)
            % First call the common code for all levels
            varval = obj.GetVar@TreeNodeClass(varname);
            
            % Now call the subject specific part
            if isempty(varval)
                varval = obj.runs(1).GetVar(varname);
            end            
        end
        
               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function SetSDG(obj,option)
            if exist('option','var')
                obj.SD = obj.runs(1).GetSDG(option);
            else
                obj.SD = obj.runs(1).GetSDG();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj,option)
            if exist('option','var')
                SD = obj.runs(1).GetSDG(option);
            else
                SD = obj.runs(1).GetSDG();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function srcpos = GetSrcPos(obj,option)
            if exist('option','var')
                srcpos = obj.runs(1).GetSrcPos(option);
            else
                srcpos = obj.runs(1).GetSrcPos();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function detpos = GetDetPos(obj,option)
            if exist('option','var')
                detpos = obj.runs(1).GetDetPos(option);
            else
                detpos = obj.runs(1).GetDetPos();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.runs(1).GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function ch = GetMeasList(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            ch = obj.runs(1).GetMeasList(iBlk);
        end
                
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.runs(1).GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, iCh] = GetDataBlocksIdxs(obj, iCh)
            if nargin<2
                iCh = [];
            end
            [iDataBlks, iCh] = obj.runs(1).GetDataBlocksIdxs(iCh);
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = obj.runs(1).GetDataBlocksNum();
        end
       
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                CondNames = {};
                for ii=1:length(obj.runs)
                    obj.runs(ii).SetConditions();
                    CondNames = [CondNames, obj.runs(ii).GetConditions()];
                end
            elseif nargin==2
                for ii=1:length(obj.runs)
                    obj.runs(ii).SetConditions(CondNames);
                end                
            end
            obj.CondNames = unique(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            for ii=1:length(obj.runs)
                CondNamesRun = obj.runs(ii).GetConditionsActive();
                for jj=1:length(CondNames)
                    k = find(strcmp(['-- ', CondNames{jj}], CondNamesRun));
                    if ~isempty(k)
                        CondNames{jj} = ['-- ', CondNames{jj}];
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            % Function to rename a condition. Important to remeber that changing the
            % condition involves 2 distinct well defined steps:
            %   a) For the current element change the name of the specified (old)
            %      condition for ONLY for ALL the acquired data elements under the
            %      currElem, be it run, subj, or group . In this step we DO NOT TOUCH
            %      the condition names of the run, subject or group .
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
            for ii=1:length(obj.runs)
                obj.runs(ii).RenameCondition(oldname, newname);
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = [];
        end
                

        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_MeanHRF(obj, trange, width, iBlk)
            if ~exist('trange','var') || isempty(trange)
                trange = [0,0];
            end
            if ~exist('width','var') || isempty(width)
                width = 12;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            tblcells = obj.procStream.GenerateTableCells_MeanHRF(obj.name, obj.CondNames, trange, width, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCellsHeader_MeanHRF(obj, widthCond, widthSubj)
            tblcells = repmat(TableCell(), length(obj.CondNames), 2);
            for iCond = 1:length(obj.CondNames)
                % First 2 columns contain condition name and group, subject or run name
                tblcells(iCond, 1) = TableCell(obj.CondNames{iCond}, widthCond);
                tblcells(iCond, 2) = TableCell(obj.name, widthSubj);
            end
        end
        
        % ----------------------------------------------------------------------------------
        function [fn_error, missing_args, prereqs] = CheckProcStreamOrder(obj)
            missing_args = {};
            fn_error = 0;
            prereqs = '';
            for i = 1:length(obj.runs)
                [fn_error, missing_args, prereqs] = obj.runs(i).CheckProcStreamOrder;
                if ~isempty(missing_args)
                    return
                end
            end
        end
        
        % ----------------------------------------------------------------------------------
        function ExportHRF(obj, procElemSelect, iBlk)
            if ~exist('procElemSelect','var') || isempty(procElemSelect)
                q = MenuBox('Export only current subject data OR current subject data and all it''s run data?', ...
                            {'Current subject data only','Current subject data and all it''s run data','Cancel'});
                if q==1
                    procElemSelect  = 'current';
                elseif q==2
                    procElemSelect  = 'all';
                else
                    return
                end
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end

            if strcmp(procElemSelect, 'all')
                for ii = 1:length(obj.runs)
                    obj.runs(ii).ExportHRF(iBlk);
                end
            end            
            obj.ExportHRF@TreeNodeClass(procElemSelect, iBlk);
        end
    
        
        % ----------------------------------------------------------------------------------
        function r = ListOutputFilenames(obj, options)
            if ~exist('options','var')
                options = '';
            end
            r = obj.GetOutputFilename(options);
            fprintf('  %s %s\n', obj.path, r);
            for ii = 1:length(obj.runs)
                obj.runs(ii).ListOutputFilenames(options);
            end
        end
        
    end
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
                
        % ----------------------------------------------------------------------------------
        function b = HaveOutput(obj)
            b = false;
            for ii = 1:length(obj.runs)
                b = obj.runs(ii).HaveOutput();
                if b
                    break;
                end
            end
        end
                
        
        % ----------------------------------------------------------------------------------
        function BackwardCompatability(obj)
            obj.BackwardCompatability@TreeNodeClass();
            for ii = 1:length(obj.runs)
                obj.runs(ii).BackwardCompatability();
            end
        end
                          
    end  % Private methods
    
end
