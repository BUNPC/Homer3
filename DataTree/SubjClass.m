classdef SubjClass < TreeNodeClass
    
    properties % (Access = private)
        sess;
    end
       
    
    methods
                
        % ----------------------------------------------------------------------------------
        function obj = SubjClass(varargin)
            obj@TreeNodeClass(varargin);
            
            obj.type  = 'subj';
            obj.sess = SessClass().empty;

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
            for ii = 1:length(obj.sess)
                nbytes = nbytes + obj.sess(ii).MemoryRequired();
            end
            nbytes = nbytes + obj.procStream.MemoryRequired();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % S to obj if obj and S are equivalent nodes
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, conditional)
            % Copy SubjClass object obj2 to SubjClass object obj. Conditional option applies 
            % only to all the sessions under this group. If == 'conditional' ONLY derived data, 
            % that is, only from procStream but NOT from acquired data is copied for all the sessions. 
            % 
            % Conversly unconditional copy copies all properties in the sessions under this subject
            if nargin==3 && strcmp(conditional, 'conditional')
                if obj.Mismatch(obj2)
                    return
                end
                for i = 1:length(obj.sess)
                    j = obj.existRun(i,obj2);
                    if (j>0)
                        obj.sess(i).Copy(obj2.sess(j), 'conditional');
                    elseif i<=length(obj2.sess)
                        obj.sess(i).Copy(obj2.sess(i), 'conditional');
                    else
                        obj.Mismatch();
                    end
                end
                obj.Copy@TreeNodeClass(obj2, 'conditional');
            else
                if nargin<3
                    conditional = '';
                end
                for i = 1:length(obj2.sess)
                    obj.sess(i) = SessClass(obj2.sess(i), conditional);
                end
                obj.Copy@TreeNodeClass(obj2);
            end
        end
        
        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            obj.CondNames = obj2.CondNames;
            for ii = 1:length(obj.sess)
                obj.sess(ii).CopyStims(obj2.sess(ii));
            end
        end
               
        
        % ----------------------------------------------------------------------------------
        % Check whether session R exists in this subject and return
        % its index if it does exist. Else return 0.
        % ----------------------------------------------------------------------------------
        function j = existRun(obj, k, S)
            j=0;
            for i=1:length(S.sess)
                [~,rname1] = fileparts(obj.sess(k).name);
                [~,rname2] = fileparts(S.sess(i).name);
                if strcmp(rname1,rname2)
                    j=i;
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of sessions are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            if ~strcmp(obj1.name, obj2.name)
                B=0;
                return;
            end
            for i = 1:length(obj1.sess)
                j = existRun(obj1, i, obj2);
                if j==0
                    B=0;
                    return;
                end
            end
            for i = 1:length(obj2.sess)
                j = existRun(obj2, i, obj1);
                if j==0
                    B=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = CheckForNameConflict(obj, sess)
            b = false;
            [~, sessname] = fileparts(sess.GetName());
            if strcmp(sessname, obj.name)
                b = true;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Add(obj, sess, run)
            [~,f,e] = fileparts(sess.GetName());
            if strcmp(f, obj.name)
                msg{1} = sprintf('WARNING: The session being added (%s) has the same name as the subject (%s) containing it. ', [f,e], obj.name);
                msg{2} = sprintf('The session names should not have the same name as the subject, otherwise '); 
                msg{3} = sprintf('it may cause incorrect results in processing. Do you want to change this session''s name?');
                obj.logger.Write('%s\n', [msg{:}]);

                % Deconflict name of subject with name of session if there is no
                % subject folder for this subject
                if ~ispathvalid(['./',obj.name], 'dir')
                    obj.name = [obj.name, '_sub'];
                    obj.logger.Write('Renaming subject to %s\n', obj.name);
                end
            end
            
            
            % Add session to this subject
            jj=0;
            for ii = 1:length(obj.sess)
                if strcmp(obj.sess(ii).GetName, sess.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.sess)+1;
                sess.SetIndexID(obj.iGroup, obj.iSubj, jj);
                sess.SetPath(obj.path);                      % Inherit root path from subject
                obj.sess(jj) = sess;
                obj.logger.Write('      Added session  "%s"  to subject  "%s" .\n', obj.sess(jj).GetFileName, obj.GetFileName);
            end
            
            % Add sess to subj
            obj.sess(jj).Add(run);
            obj.children = obj.sess;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function list = DepthFirstTraversalList(obj)
            list{1} = obj;
            for ii = 1:length(obj.sess)
                list = [list; obj.sess(ii).DepthFirstTraversalList()];
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
                for jj = 1:length(obj.sess)
                    obj.sess(jj).Reset();
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
            err2 = obj.sess(1).Load();
            if err1==0 && err2==0
                err = 0;
            end
        end            

        
        % ----------------------------------------------------------------------------------
        function FreeMemorySubBranch(obj)
            if isempty(obj)
                return;
            end
            obj.sess(1).FreeMemory()
        end            
            
        
        % ----------------------------------------------------------------------------------
        function FreeMemoryRecursive(obj)
            if isempty(obj)
                return
            end
            for ii = 1:length(obj.sess)
                obj.sess(ii).FreeMemory();
            end
            obj.FreeMemory();
        end
        


        % ----------------------------------------------------------------------------------
        function LoadRecursive(obj)
            if isempty(obj)
                return
            end
            for ii = 1:length(obj.sess)
                obj.sess(ii).Load();
            end
            obj.Load();
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
        function LoadInputVars(obj, tHRF_common)
            obj.inputVars.nTrialsSess = [];
            for iSess = 1:length(obj.sess)
                % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
                % all sessions. Use smallest tHRF as the common one.
                obj.sess(iSess).procStream.output.SettHRFCommon(tHRF_common, obj.sess(iSess).name, obj.sess(iSess).type);
                
                obj.inputVars.dodAvgSess{obj.sess(iSess).iSess}    = obj.sess(iSess).procStream.output.GetVar('dodAvg');
                obj.inputVars.dodAvgStdSess{obj.sess(iSess).iSess} = obj.sess(iSess).procStream.output.GetVar('dodAvgStd');
                obj.inputVars.dodSum2Sess{obj.sess(iSess).iSess}   = obj.sess(iSess).procStream.output.GetVar('dodSum2');
                obj.inputVars.dcAvgSess{obj.sess(iSess).iSess}     = obj.sess(iSess).procStream.output.GetVar('dcAvg');
                obj.inputVars.dcAvgStdSess{obj.sess(iSess).iSess}  = obj.sess(iSess).procStream.output.GetVar('dcAvgStd');
                obj.inputVars.dcSum2Sess{obj.sess(iSess).iSess}    = obj.sess(iSess).procStream.output.GetVar('dcSum2');
                obj.inputVars.tHRFSess{obj.sess(iSess).iSess}      = obj.sess(iSess).procStream.output.GetTHRF();
                obj.inputVars.mlActSess{obj.sess(iSess).iSess}     = obj.sess(iSess).procStream.output.GetVar('mlActAuto');
                if isempty(obj.inputVars.nTrialsSess)
                    obj.inputVars.nTrialsSess                      = obj.sess(iSess).procStream.output.GetVar('nTrials');
                else
                    nTrialsSess                                    = obj.sess(iSess).procStream.output.GetVar('nTrials');
                    for iBlk = 1:length(obj.inputVars.nTrialsSess)
                        obj.inputVars.nTrialsSess{iBlk}            = obj.inputVars.nTrialsSess{iBlk} + nTrialsSess{iBlk};
                    end
                end
                if ~isempty(obj.sess(iSess).procStream.output.GetVar('misc'))
                    if isfield(obj.sess(iSess).procStream.output.misc, 'stim') == 1
                        obj.inputVars.stimSess{obj.sess(iSess).iSess}      = obj.sess(iSess).procStream.output.misc.stim;
                    else
                        obj.inputVars.stimSess{obj.sess(iSess).iSess}      = obj.sess(iSess).GetVar('stim');
                    end
                else
                    obj.inputVars.stimSess{obj.sess(iSess).iSess}      = obj.sess(iSess).GetVar('stim');
                end
                obj.inputVars.dcSess{obj.sess(iSess).iSess}       = obj.sess(iSess).procStream.output.GetVar('dc');
                obj.inputVars.AauxSess{obj.sess(iSess).iSess}      = obj.sess(iSess).procStream.output.GetVar('Aaux');
                obj.inputVars.tIncAutoSess{obj.sess(iSess).iSess}  = obj.sess(iSess).procStream.output.GetVar('tIncAuto');
                obj.inputVars.rcMapSess{obj.sess(iSess).iSess}     = obj.sess(iSess).procStream.output.GetVar('rcMap');
                
                % a) Find all variables needed by proc stream
                args = obj.procStream.GetInputArgs();
                
                % b) Find these variables in this session
                for ii = 1:length(args)
                    if ~eval( sprintf('isproperty(obj.inputVars, ''%s'')', args{ii}) )
                        eval( sprintf('obj.inputVars.%s = obj.GetVar(args{ii});', args{ii}) );
                    end
                end
                
                % Free session memory
                obj.sess(iSess).FreeMemory()
            end
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
            
            % Calculate all sessions in this session and generate common tHRF
            tHRF_common = {};
            for iSess = 1:length(obj.sess)
                obj.sess(iSess).Calc();

                % Find smallest tHRF among the subjects and make this the common one.
                tHRF_common = obj.sess(iSess).procStream.output.GeneratetHRFCommon(tHRF_common);
            end
            
            % Update call application GUI using it's generic Update function 
            if ~isempty(obj.updateParentGui)
                obj.updateParentGui('DataTreeClass', [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]);
            end
            
            % Load all the variables that might be needed by procStream.Calc() to calculate proc stream for this subject
            obj.LoadInputVars(tHRF_common);
                        
            Calc@TreeNodeClass(obj);

            if obj.DEBUG
                fprintf('Completed processing stream for group %d, subject %d\n', obj.iGroup, obj.iSubj);
                fprintf('\n');
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
            for ii = 1:length(obj.sess)
                obj.sess(ii).Print(indent);
            end
        end
        

        % ---------------------------------------------------------------
        function PrintProcStream(obj)
            fcalls = obj.procStream.GetFuncCallChain();
            obj.logger.Write('Subject processing stream:\n');
            for ii = 1:length(fcalls)
                obj.logger.Write('%s\n', fcalls{ii});
            end
            obj.logger.Write('\n');
            obj.sess(1).PrintProcStream();
        end
        
            
            
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            for ii = 1:length(obj.sess)
                if ~obj.sess(ii).IsEmpty()
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
            for ii = 1:length(obj.sess)
                if ~obj.sess(ii).IsEmptyOutput()
                    b = false;
                    break;
                end
            end
        end


        % ----------------------------------------------------------------------------------
        function SaveAcquiredData(obj)            
            for ii = 1:length(obj.sess)
                obj.sess(ii).SaveAcquiredData();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = AcquiredDataModified(obj)
            b = false;
            for ii = 1:length(obj.sess)
                if obj.sess(ii).AcquiredDataModified()
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
                varval = obj.sess(1).GetVar(varname);
            end            
        end
        
               
         % --------------------------------------------------------------------------
        function ApplyParamEditsToAllSessions(obj, iFcall, iParam, val)
            for jj = 1:length(obj.sess)
                obj.sess(jj).procStream.EditParam(iFcall, iParam, val);
            end
        end
        
        
        % --------------------------------------------------------------------------
        function ApplyParamEditsToAllRuns(obj, iFcall, iParam, val)
            for jj = 1:length(obj.sess)
                obj.sess(jj).ApplyParamEditsToAllRuns(iFcall, iParam, val);
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
                obj.SD = obj.sess(1).GetSDG(option);
            else
                obj.SD = obj.sess(1).GetSDG();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj,option)
            if exist('option','var')
                SD = obj.sess(1).GetSDG(option);
            else
                SD = obj.sess(1).GetSDG();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.sess(1).GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function probe = GetProbe(obj)
            probe = obj.sess(1).GetProbe();
        end
        
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.sess(1).GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, iCh] = GetDataBlocksIdxs(obj, iCh)
            if nargin<2
                iCh = [];
            end
            [iDataBlks, iCh] = obj.sess(1).GetDataBlocksIdxs(iCh);
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = obj.sess(1).GetDataBlocksNum();
        end
       
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                CondNames = {};
                for ii = 1:length(obj.sess)
                    obj.sess(ii).SetConditions();
                    CondNames = [CondNames, obj.sess(ii).GetConditions()];
                end
            elseif nargin==2
                for ii = 1:length(obj.sess)
                    obj.sess(ii).SetConditions(CondNames);
                end                
            end
            obj.CondNames = unique(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            for ii = 1:length(obj.sess)
                CondNamesRun = obj.sess(ii).GetConditionsActive();
                for jj=1:length(CondNames)
                    k = find(strcmp(['-- ', CondNames{jj}], CondNamesRun));
                    if ~isempty(k)
                        CondNames{jj} = ['-- ', CondNames{jj}];
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = [];
        end
                

        % ----------------------------------------------------------------------------------
        function [fn_error, missing_args, prereqs] = CheckProcStreamOrder(obj)
            missing_args = {};
            fn_error = 0;
            prereqs = '';
            for i = 1:length(obj.sess)
                [fn_error, missing_args, prereqs] = obj.sess(i).CheckProcStreamOrder;
                if ~isempty(missing_args)
                    return
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function r = ListOutputFilenames(obj, options)
            if ~exist('options','var')
                options = '';
            end
            r = obj.GetOutputFilename(options);
            fprintf('  %s %s\n', obj.path, r);
            for ii = 1:length(obj.sess)
                obj.sess(ii).ListOutputFilenames(options);
            end
        end
                
    end
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
                
        % ----------------------------------------------------------------------------------
        function BackwardCompatability(obj)
            obj.BackwardCompatability@TreeNodeClass();
            for ii = 1:length(obj.sess)
                obj.sess(ii).BackwardCompatability();
            end
        end
                          
    end  % Private methods
    
end
