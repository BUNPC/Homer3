classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        version;
        versionStr;
        subjs;
    end
    
    properties % (Access = private)
        outputFilename
        oldDerivedPaths
        derivedPathBidsCompliant
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = GroupClass(varargin)
            obj@TreeNodeClass(varargin);

            obj.InitVersion();
            obj.oldDerivedPaths = {obj.path, [obj.path, 'homerOutput']};
            obj.derivedPathBidsCompliant = 'derivatives/homer';
            
            if nargin<3 || ~strcmp(varargin{3}, 'noprint')
                obj.logger.Write('Current GroupClass version %s\n', obj.GetVersionStr());
            end
            
            obj.type    = 'group';
            obj.subjs   = SubjClass().empty;
                        
            obj.outputFilename = obj.cfg.GetValue('Output File Name');
            if isempty(obj.outputFilename)
                obj.outputFilename = 'groupResults.mat';
            end
            
            if nargin==0
                return;
            end
            if nargin>0
                if ischar(varargin{1}) && strcmp(varargin{1},'copy')
                    return;
                elseif isa(varargin{1}, 'GroupClass')
                    obj.Copy(varargin{1});
                    return;
                end
                if isa(varargin{1}, 'FileClass')
                    obj.name = varargin{1}.ExtractNames();
                else
                    obj.name = varargin{1};
                end
            end
            if nargin>1
                obj.iGroup = varargin{2};
            end
                        
            if isempty(obj.name)
                % Derive obj name from the name of the root directory
                curr_dir = pwd;
                k = sort([findstr(curr_dir,'/') findstr(curr_dir,'\')]); %#ok<*FSTR>
                obj.name = curr_dir(k(end)+1:end);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function InitVersion(obj)
            obj.SetVersion();
            obj.InitVersionStrFull();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetVersion(obj, vernum)
            % Version number should be incremented whenever properties are added, deleted or changed in 
            % GroupClass, SubjectClass, RunClass OR acquisition class, like AcqDataClass, SnirfClass and 
            % its sub-classes or NirsClass 
            
            if nargin==1
                obj.version{1} = '2';   % Major version #
                obj.version{2} = '0';   % Major sub-version #
                obj.version{3} = '0';   % Minor version #
                obj.version{4} = '0';   % Minor sub-version # or patch #: 'p1', 'p2', etc
            elseif iscell(vernum)
                if ~isnumber([vernum{:}])
                    return;
                end
                for ii=1:length(vernum)
                    obj.version{ii} = vernum{ii};
                end
            elseif ischar(vernum)
                vernum = str2cell(vernum,'.');
                if ~isnumber([vernum{:}])
                    return;
                end
                obj.version = cell(length(vernum),1);
                for ii=1:length(vernum)
                    obj.version{ii} = vernum{ii};
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function vernum = GetVersion(obj)
            vernum = obj.version;
        end
        
        
        % ----------------------------------------------------------------------------------
        function verstr = GetVersionStr(obj)
            verstr = version2string(obj.version);
        end
        
        
        % ----------------------------------------------------------------------------------
        function filename = GetFilename(obj)
            filename = obj.outputFilename;
        end
        
        
        % ----------------------------------------------------------------------------------
        function InitVersionStrFull(obj)
            if isempty(obj.version)
                return;
            end
            verstr = version2string(obj.version);
            obj.versionStr = sprintf('GroupClass v%s', verstr);
        end
        
        
        % ----------------------------------------------------------------------------------
        function res = CompareVersions(obj, obj2)
            res = 1;
            if ~isproperty(obj, 'version')
                return;
            elseif ~ischar(obj2.version) && ~iscell(obj2.version) 
                return;
            elseif ischar(obj2.version)
                if ~isnumber(obj2.version)
                    return;                    
                end
                v2 = str2cell(obj2.version,'.');
            elseif iscell(obj2.version)
                v2 = obj2.version;
            end
            v1 = obj.version;
            
            for ii=1:length(v1)
                v1{ii} = str2num(v1{ii}); %#ok<*ST2NM>
            end
            for ii=1:length(v2)
                v2{ii} = str2num(v2{ii});
            end
            
            % Now that we have the version numbers of both objects, we can
            % do an actual numeric comparison
            res = 0;
            for ii=1:max(length(v1), length(v2))
                if ii>length(v1)
                    res = -1;
                    break;
                end
                if ii>length(v2)
                    res = 1;
                    break;
                end
                if v1{ii}>v2{ii}
                    res = 1;
                    break;
                end
                if v1{ii}<v2{ii}
                    res = -1;
                    break;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Groups obj1 and obj2 are considered equivalent if their names
        % are equivalent and their subject sets are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            if ~strcmp(obj1.name, obj2.name)
                B=0;
                return;
            end
            for i=1:length(obj1.subjs)
                j = existSubj(obj1, i, obj2);
                if j==0 || (obj1.subjs(i) ~= obj2.subjs(j))
                    B=0;
                    return;
                end
            end
            for i=1:length(obj2.subjs)
                j = existSubj(obj2, i, obj1);
                if j==0 || (obj2.subjs(i) ~= obj1.subjs(j))
                    B=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, conditional)
            % Copy GroupClass object obj2 to GroupClass object obj. Conditional option applies 
            % only to all the runs under this group. If == 'conditional' ONLY derived data, 
            % that is, only from procStream but NOT from acquired data is copied for all the runs. 
            % 
            % Conversly unconditional copy copies all properties in the runs under this group
            if nargin==3 && strcmp(conditional, 'conditional')
                if obj.Mismatch(obj2)
                    return
                end
                for i = 1:length(obj.subjs)
                    j = obj.existSubj(i,obj2);
                    if j>0
                        obj.subjs(i).Copy(obj2.subjs(j), 'conditional');
                    elseif i<=length(obj2.subjs)
                        obj.subjs(i).Copy(obj2.subjs(i), 'conditional');
                    else
                        obj.subjs(i).Mismatch();
                    end
                end                
                obj.Copy@TreeNodeClass(obj2, 'conditional');
            else
                for i=1:length(obj2.subjs)
                    obj.subjs(i) = SubjClass(obj2.subjs(i));
                end
                obj.Copy@TreeNodeClass(obj2);
            end
        end

        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            obj.CondNames = obj2.CondNames;
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).CopyStims(obj2.subjs(ii));
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CopyFcalls(obj, varargin)
            if isa(varargin{1},'TreeNodeClass')
                procStream  = varargin{1}.procStream;
                type        = varargin{1}.type;
            elseif isa(varargin{1},'ProcStreamClass')
                procStream  = varargin{1};
                type        = varargin{2};
            end
            
            % Copy default procStream function call chain to all uninitialized nodes 
            % in the group
            switch(type)
                case 'group'
                    obj.procStream.CopyFcalls(procStream);
                case 'subj'
                    for jj = 1:length(obj.subjs)
                        obj.subjs(jj).procStream.CopyFcalls(procStream);
                    end
                case 'sess'
                    for ii = 1:length(obj.subjs)
                        for jj = 1:length(obj.subjs(ii).sess)
                            obj.subjs(ii).sess(jj).procStream.CopyFcalls(procStream);
                        end
                    end
                case 'run'
                    for ii = 1:length(obj.subjs)
                        for jj = 1:length(obj.subjs(ii).sess)
                            for kk = 1:length(obj.subjs(ii).sess(jj).runs)
                                obj.subjs(ii).sess(jj).runs(kk).procStream.CopyFcalls(procStream);
                            end
                        end
                    end
            end
        end

        
        
        % ----------------------------------------------------------------------------------
        function Add(obj, subj, sess, run)
            [~,f,e] = fileparts(subj.GetName());
            if strcmp(f, obj.name)
                msg{1} = sprintf('WARNING: The subject being added (%s) has the same name as the group (%s) containing it. ', [f,e], obj.name);
                msg{2} = sprintf('The subject names should not have the same name as the group folder, otherwise '); 
                msg{3} = sprintf('it may cause incorrect results in processing.');
                obj.logger.Write('%s\n', [msg{:}]);
            end
            
            % Add subject to this group
            jj = 0;
            for ii = 1:length(obj.subjs)
                if strcmp(obj.subjs(ii).GetName(), subj.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.subjs)+1;
                subj.SetIndexID(obj.iGroup, jj);
                subj.SetPath(obj.path);                      % Inherit root path from group
                obj.subjs(jj) = subj;
                obj.logger.Write('   Added subject  "%s"  to group  "%s" .\n', obj.subjs(jj).GetFileName, obj.GetFileName);
            end
                        
            % Add sess to subj
            obj.subjs(jj).Add(sess, run);
            obj.children = obj.subjs;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function list = DepthFirstTraversalList(obj)
            list{1} = obj;
            for ii=1:length(obj.subjs)
                list = [list; obj.subjs(ii).DepthFirstTraversalList()];
            end
        end
        
        
        
        % #########################################################################
            
            
        % -----------------------------------------------------------------------------
        function [g, s, e, r] = GetInitialFuncCallChain(obj)
            g = obj;
            s = obj.subjs(1);
            e = obj.subjs(1).sess(1);
            r = obj.subjs(1).sess(1).runs(1);
            for ii = 1:length(obj.subjs)
                if ~obj.subjs(ii).procStream.IsEmpty()
                    s = obj.subjs(ii);
                end
                for jj = 1:length(obj.subjs(ii).sess)
                    if ~obj.subjs(ii).sess(jj).procStream.IsEmpty()
                        e = obj.subjs(ii).sess(jj);
                    end
                    for kk = 1:length(obj.subjs(ii).sess(jj).runs)
                        if ~obj.subjs(ii).sess(jj).runs(kk).procStream.IsEmpty()
                            r = obj.subjs(ii).sess(jj).runs(kk);
                        end
                    end
                end
            end
            
            % Generate procStream defaults at each level with which to initialize
            % any uninitialized procStream.input
            g.CreateProcStreamDefault();           
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function [fnameFull, status] = InitProcStreamLevel(obj, g, o, fnameFull)
            status = 0;
            
            procStreamDefault = o.GetProcStreamDefault();
            
            % If any of the tree nodes still have unintialized procStream input, ask
            % user for a config file to load it from
            if o.procStream.IsEmpty()                
                
                if ~ispathvalid(fnameFull)
                    [fnameFull, autoGenDefaultFile] = g.procStream.GetConfigFileName(fnameFull, obj.path);
                else
                    autoGenDefaultFile = false;
                end
                
                % If user did not provide procStream config filename and file does not exist
                % then create a config file with the default contents
                if ~exist(fnameFull, 'file')
                    procStreamDefault.SaveConfigFile(fnameFull, o.type);
                end
                
                obj.logger.Write('Attempting to load %s-level proc stream from %s\n', o.type, fnameFull);
                
                % Load file to the first empty procStream in the dataTree at each processing level
                err = o.LoadProcStreamConfigFile(fnameFull);

                % If proc stream input is still empty it means the loaded config
                % did not have valid proc stream input. If that's the case we
                % Load a default proc stream input
                if err ~= 0
                    [~, fname, ext] = fileparts(fnameFull);
                    msg{1} = sprintf('Some functions at the %s-level failed to load from selected proc stream config file,  "%s".  ', o.type, [fname, ext]);
                    msg{2} = sprintf('The functions may be obsolete or contain errors.  Loading default %s proc stream ...\n', o.type);
                    obj.logger.Write([msg{:}]);
                    g.CopyFcalls(procStreamDefault, o.type);
                    status = 1;
                    
                % Otherwise the non-default processing stream loaded from file to this group and to first subject
                % disseminate it to all subjects and all runs in this group
                else
                    
                    obj.logger.Write('Loading proc stream from %s\n', fnameFull);
                    g.CopyFcalls(o.procStream, o.type);
                    
                end
                
            end
        end


        
        % ----------------------------------------------------------------------------------
        function ErrorCheckInitErr(obj, procStreamCfgFile, status);
            if ~all(status==0)
                [~, fname, ext] = fileparts(procStreamCfgFile);
                levels = '';
                if status(1)~=0
                    levels = 'group';                    
                end
                if status(2)~=0
                    if isempty(levels)
                        levels = 'subject';
                    else
                        levels = [levels, ', subject'];
                    end
                end
                if status(3)~=0
                    if isempty(levels)
                        levels = 'session';
                    else
                        levels = [levels, ', session'];
                    end
                end
                if status(4)~=0
                    if isempty(levels)
                        levels = 'run';
                    else
                        levels = [levels, ', run'];
                    end
                end
                k = find(levels == ',');
                if ~isempty(k)
                    levels = sprintf('%s and %s levels', levels(1:k-1), levels(k+2:end));
                    procStreamLabelPlural = 'streams';
                else
                    levels = sprintf('%s level', levels);
                    procStreamLabelPlural = 'stream';
                end
                msg{1} = sprintf('\nWARNING: There were errors loading user functions from "%s" at the %s.\n', [fname, ext], levels);
                msg{2} = sprintf('These functions may have changed since this file was created or have errors in the help\n');
                msg{3} = sprintf('sections of the processing stream description. Replacing %s processing\n', levels);
                msg{4} = sprintf('%s with default processing %s ... \n', procStreamLabelPlural, procStreamLabelPlural);
                % if strcmpi(obj.cfg.GetValue('Include Archived User Functions'), 'No')
                %       MenuBox(msg, {'OK'});
                % end
                obj.logger.Write([msg{:}]);
            end
        end
    
        
        
        % ----------------------------------------------------------------------------------
        function InitProcStream(obj, procStreamCfgFile)
            if isempty(obj)
                return;
            end
            
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find out if we need to ask user for processing options
            % config file to initialize procStream.fcalls at the
            % run, subject or group level. First try to find the proc
            % input at each level from the saved derived data.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [g, s, e, r] = obj.GetInitialFuncCallChain();
            
            % 
            [procStreamCfgFile, status(1)] = obj.InitProcStreamLevel(g, g, procStreamCfgFile);
            [procStreamCfgFile, status(2)] = obj.InitProcStreamLevel(g, s, procStreamCfgFile);
            [procStreamCfgFile, status(3)] = obj.InitProcStreamLevel(g, e, procStreamCfgFile);
            [~,                 status(4)] = obj.InitProcStreamLevel(g, r, procStreamCfgFile);
            
            obj.ErrorCheckInitErr(procStreamCfgFile, status);                        
        end
        
        
        
        
        % ---------------------------------------------------------------
        function PrintProcStream(obj)
            fcalls = obj.procStream.GetFuncCallChain();
            obj.logger.Write('Group processing stream:\n');
            for ii = 1:length(fcalls)
                obj.logger.Write('%s\n', fcalls{ii});
            end
            obj.logger.Write('\n');
            obj.subjs(1).PrintProcStream();
        end
        
            
            
       % ----------------------------------------------------------------------------------
        function FreeMemoryRecursive(obj)
            if isempty(obj)
                return
            end
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).FreeMemoryRecursive();
            end
            obj.FreeMemory();
        end
        


        % ----------------------------------------------------------------------------------
        function LoadRecursive(obj)
            if isempty(obj)
                return
            end
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).LoadRecursive();
            end
            obj.Load();
        end
                
            
            
        % ----------------------------------------------------------------------------------
        function LoadInputVars(obj, tHRF_common)
            obj.inputVars = [];
            for iSubj = 1:length(obj.subjs)
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all subjects. Use smallest tHRF as the common one.
                obj.subjs(iSubj).procStream.output.SettHRFCommon(tHRF_common, obj.subjs(iSubj).name, obj.subjs(iSubj).type);
            
                obj.inputVars.dodAvgSubjs{obj.subjs(iSubj).iSubj}    = obj.subjs(iSubj).procStream.output.GetVar('dodAvg');
                obj.inputVars.dodAvgStdSubjs{obj.subjs(iSubj).iSubj} = obj.subjs(iSubj).procStream.output.GetVar('dodAvgStd');
                obj.inputVars.dcAvgSubjs{obj.subjs(iSubj).iSubj}     = obj.subjs(iSubj).procStream.output.GetVar('dcAvg');
                obj.inputVars.dcAvgStdSubjs{obj.subjs(iSubj).iSubj}  = obj.subjs(iSubj).procStream.output.GetVar('dcAvgStd');
                obj.inputVars.tHRFSubjs{obj.subjs(iSubj).iSubj}      = obj.subjs(iSubj).procStream.output.GetTHRF();
                obj.inputVars.nTrialsSubjs{obj.subjs(iSubj).iSubj}   = obj.subjs(iSubj).procStream.output.GetVar('nTrials');
            
                obj.subjs(iSubj).FreeMemory();
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
                obj.logger.Write('Calculating processing stream for group %d\n', obj.iGroup)
            end
            
            % Calculate all subjs in this session
            tHRF_common = {};
            for iSubj = 1:length(obj.subjs)
                obj.subjs(iSubj).Calc();
                
                % Find smallest tHRF among the subjs and make this the common one.
                tHRF_common = obj.subjs(iSubj).procStream.output.GeneratetHRFCommon(tHRF_common);
            end
           
            
            % Load all the output valiraibles that might be needed by procStream.Calc() to calculate proc stream for this group
            obj.LoadInputVars(tHRF_common); 
            
            Calc@TreeNodeClass(obj);
            
            if obj.DEBUG
                obj.logger.Write('Completed processing stream for group %d\n', obj.iGroup);
                obj.logger.Write('\n');
            end
            
            % Update call application GUI using it's generic Update function
            if ~isempty(obj.updateParentGui)
                obj.updateParentGui('DataTreeClass', [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]);
            end
            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            obj.logger.Write('\n');
            if ~exist('indent', 'var')
                indent = 0;
            end
            Print@TreeNodeClass(obj, indent);
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).Print(indent);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procStream.output
        % ----------------------------------------------------------------------------------
        function Reset(obj, option)
            if ~exist('option','var')
                option = 'down';
            end
            if exist([obj.path, obj.outputDirname, obj.outputFilename],'file')
                delete([obj.path, obj.outputDirname, obj.outputFilename]);
            end
            if strcmp(option, 'down')
                for jj = 1:length(obj.subjs)
                    obj.subjs(jj).Reset();
                end
            end
            Reset@TreeNodeClass(obj);
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            for ii = 1:length(obj.subjs)
                if ~obj.subjs(ii).IsEmpty()
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
            for ii = 1:length(obj.subjs)
                if ~obj.subjs(ii).IsEmptyOutput()
                    b = false;
                    break;
                end
            end
        end


    end   % Public methods
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Save/Load methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            for ii = 1:length(obj.subjs)
                nbytes = nbytes + obj.subjs(ii).MemoryRequired();
            end
            nbytes = nbytes + obj.procStream.MemoryRequired();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = LoadSubBranch(obj)
            err = -1;
            if isempty(obj)
                return;
            end
            err1 = obj.procStream.Load([obj.path, obj.GetOutputFilename()]);
            err2 = obj.subjs(1).LoadSubBranch();
            if err1==0 && err2==0
                err = 0;
            end
        end            
                        
            
        % ----------------------------------------------------------------------------------
        function FreeMemorySubBranch(obj)
            if isempty(obj)
                return;
            end
            obj.subjs(1).FreeMemorySubBranch()
        end            
            
        
        % ----------------------------------------------------------------------------------
        function err = Load(obj, options)
            err = -1;
            if isempty(obj)
                return;
            end
            if ~exist('options','var')
                options = '';
            end
            
            % If this group has been loaded, then no need to go through the whole Load function. Instead 
            % default to the generic TreeNodeClass.Load method.
            if ~optionExists(options, {'init','reload'})
                err = obj.Load@TreeNodeClass();
                return;
            end
            
            obj.BackwardCompatability();

            group = [];
            if ispathvalid([obj.path, obj.outputDirname, obj.outputFilename],'file')
                g = load([obj.path, obj.outputDirname, obj.outputFilename]);
                
                % Do some basic error checks on saved derived data contents
                if isproperty(g, 'group') && isa(g.group, 'GroupClass')
                    if isproperty(g.group, 'version')
                        if ismethod(g.group, 'GetVersion')
                            obj.logger.Write('Saved group data, version %s exists\n', g.group.GetVersionStr());
                            group = g.group;
                        end
                    end
                end
            end
            
            % Copy saved group to current group if versions are compatible. obj.CompareVersions==0 
            % means the versions of the saved group and current one are equal.
            if ~isempty(group) && obj.CompareVersions(group)<=0
                % Do a conditional copy of group from saved processing output file. Conditional copy copies ONLY 
                % derived data, that is, only from procStream but NOT acqruired. We do not want to 
                % overwrite the real acquired data loaded from acquisition files 
                hwait = waitbar(0,'Loading group');
                obj.Copy(group, 'conditional');
                close(hwait);
            else
                if exist([obj.path, obj.outputDirname, obj.outputFilename],'file')
                    obj.logger.Write('Warning: This folder contains old version of processing results. Will move it to *_old.mat\n');
                    [~,outputFilename] = fileparts(obj.outputFilename); %#ok<*PROPLC>
                    movefile([obj.path, obj.outputDirname, obj.outputFilename], [obj.path, obj.outputDirname, outputFilename, '_old.mat'])
                end
                obj.Save();
            end
            err = 0;
        end
        
        
     
        % ----------------------------------------------------------------------------------
        function Save(obj, hwait)
            if ~exist('hwait','var')
                hwait = [];
            end            
            
            obj.logger.Write('Saving processed data in %s\n', [obj.path, obj.outputDirname, obj.outputFilename]);
            
            if ishandle(hwait)
                obj.logger.Write('Auto-saving processing results ...\n', obj.logger.ProgressBar(), hwait);
            end
            
            group = GroupClass(obj);
            try 
                obj.CreateOutputDir();
                save([obj.pathOutputAlt, obj.outputDirname, obj.outputFilename], 'group');
            catch ME
                MessageBox(ME.message);
                obj.logger.Write(ME.message);
            end            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CreateOutputDir(obj)
            if ispathvalid([obj.pathOutputAlt, obj.outputDirname])
                return;
            end
            mkdir([obj.pathOutputAlt, obj.outputDirname]);
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).CreateOutputDir();
            end
        end
            
           
        
        % ----------------------------------------------------------------------------------
        function SaveAcquiredData(obj)            
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).SaveAcquiredData();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = AcquiredDataModified(obj)
            b = false;
            for ii = 1:length(obj.subjs)
                if obj.subjs(ii).AcquiredDataModified()
                    b = true;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname)
            % First call the common code for all levels
            varval = obj.GetVar@TreeNodeClass(varname);
            
            % Now call the group specific part
            if isempty(varval)
                varval = obj.subjs(1).GetVar(varname);
            end            
        end
        
    end  % Public Save/Load methods
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        
        % ----------------------------------------------------------------------------------
        function probe = GetProbe(obj)
            probe = obj.subjs(1).GetProbe();
%             for subj = obj.subjs
%                 for sess = subj.sess
%                    for run = sess.runs
%                         if ~(probe == run.GetProbe()) 
%                             warning(['Probe ', run.name, ' differs from ', obj.subjs(1).sess(1).runs(1).name]) 
%                         end
%                    end   
%                 end
%             end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj,option)
            if exist('option','var')
                SD = obj.subjs(1).GetSDG(option);
            else
                SD = obj.subjs(1).GetSDG();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.subjs(1).GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.subjs(1).GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, ich] = GetDataBlocksIdxs(obj, ich)
            if nargin<2
                ich = [];
            end
            [iDataBlks, ich] = obj.subjs(1).GetDataBlocksIdxs(ich);
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = obj.subjs(1).GetDataBlocksNum();
        end
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj) %#ok<MANU>
            aux = [];
        end
                
    end      % Public Set/Get methods

        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Conditions related methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj)
            if isempty(obj)
                return;
            end
            
            % First get global et of conditions across all runs and
            % subjects
            CondNames = {};
            for ii=1:length(obj.subjs)
                obj.subjs(ii).SetConditions();
                CondNames = [CondNames, obj.subjs(ii).GetConditions()];
            end
            obj.CondNames    = unique(CondNames);
           
            % Now that we have all conditions, set the conditions across 
            % the whole group to these
            for ii=1:length(obj.subjs)
                obj.subjs(ii).SetConditions(obj.CondNames);
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [fn_error, missing_args, prereqs] = CheckProcStreamOrder(obj)
            missing_args = {};
            fn_error = 0;
            prereqs = '';
            for i = 1:length(obj.subjs)
                [fn_error, missing_args, prereqs] = obj.subjs(i).CheckProcStreamOrder;
                if ~isempty(missing_args)
                    return
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            for ii=1:length(obj.subjs)
                CondNamesSubj = obj.subjs(ii).GetConditionsActive();
                for jj=1:length(CondNames)
                    k = find(strcmp(['-- ', CondNames{jj}], CondNamesSubj));
                    if ~isempty(k)
                        CondNames{jj} = ['-- ', CondNames{jj}];
                    end
                end
            end
        end

        
        % ----------------------------------------------------------------------------------
        function r = ListOutputFilenames(obj, options)
            if ~exist('options','var')
                options = '';
            end
            r = obj.GetOutputFilename(options);
            fprintf('%s %s\n', obj.path, r);
            for ii = 1:length(obj.subjs)
                obj.subjs(ii).ListOutputFilenames(options);
            end
        end
        
        
        % ---------------------------------------------------------------
        function CleanUpOutput(obj, filesObsolete)
            for jj = 1:length(filesObsolete)
                renameFlag = false;
                for ii = 1:length(filesObsolete(jj).files)
                    if isempty(filesObsolete(jj).files(ii).namePrev)
                        continue;
                    end
                    renameFlag = true;
                end
                
                % If something changed in the folder structure 
                if renameFlag
                    msg{1} = sprintf('Previous Homer3 processing output exists but is now inconsistent with the current ');
                    msg{2} = sprintf('data files. This output should be regenerated in the new Homer3 session to reflect the new file/folder names. ');
                    msg{3} = sprintf('The existing Homer processing output will be moved to %s. Is this okay?', obj.GetArchivedOutputDirname());
                    q = MenuBox(msg,{'YES','NO'});
                    if q==1
                        if isempty(obj.outputDirname)
                            movefile('*.mat', obj.GetArchivedOutputDirname())
                            movefile('*.txt', obj.GetArchivedOutputDirname())
                        else
                            movefile(obj.outputDirname, obj.GetArchivedOutputDirname())                            
                        end
                        obj.Save();
                    end
                end
            end
        end
        
        
        
        % -----------------------------------------------------------------
        function name = GetArchivedOutputDirname(obj)
            n = 1;
            addon = '_old';
            if isempty(obj.outputDirname)
                base = 'homerOutput';
            else
                base = filesepStandard(obj.outputDirname, 'file');
            end
            name = sprintf('%s%s%d', base, addon, n);
            while ispathvalid(name)
                n = n+1;
                name = sprintf('%s%s%d', base, addon, n);
            end
        end
       
        
        
        % --------------------------------------------------------------------------
        function ApplyParamEditsToAllSubjects(obj, iFcall, iParam, val)
            for jj = 1:length(obj.subjs)
                obj.subjs(jj).procStream.EditParam(iFcall, iParam, val);
            end
        end
        
        
        % --------------------------------------------------------------------------
        function ApplyParamEditsToAllSessions(obj, iFcall, iParam, val)
            for jj = 1:length(obj.subjs)
                obj.subjs(jj).ApplyParamEditsToAllSessions(iFcall, iParam, val);
            end
        end
        
        
        % --------------------------------------------------------------------------
        function ApplyParamEditsToAllRuns(obj, iFcall, iParam, val)
            for jj = 1:length(obj.subjs)
                obj.subjs(jj).ApplyParamEditsToAllRuns(iFcall, iParam, val);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        
        % ----------------------------------------------------------------------------------
        % Check whether subject k'th subject from this group exists in group G and return
        % its index in G if it does exist. Else return 0.
        % ----------------------------------------------------------------------------------        
        function j = existSubj(obj, k, G)
            j=0;
            for i=1:length(G.subjs)
                if strcmp(obj.subjs(k).name, G.subjs(i).name)
                    j=i;
                    break;
                end
            end
        end
        

        % ----------------------------------------------------------------------------------
        function BackwardCompatability(obj)
            for jj = 1:length(obj.oldDerivedPaths)
                oldDerivedPath = filesepStandard(obj.oldDerivedPaths{jj});
                if ispathvalid([oldDerivedPath, 'groupResults.mat'])
                    try
                        g = load([oldDerivedPath, 'groupResults.mat']);
                    catch
                        g = [];
                    end
                    
                    % Do not try to restore old data older than Homer3
                    if isempty(g)
                        return;
                    end
                    if ~isproperty(g,'group')
                        return;
                    end
                    if ~isa(g.group, 'GroupClass')
                        return;
                    end
                    
                    % Do not try to restore old data if there is already data
                    % in the new format
                    if obj.HaveOutput()
                        return;
                    end
                    
                    oldDerivedPathRel = pathsubtract(oldDerivedPath, obj.path);
                    if oldDerivedPathRel(end) == '/' || oldDerivedPathRel(end) == '\'
                        oldDerivedPathRel(end) = '';
                    end
                    msg{1} = sprintf('Detected derived data in older Homer3 folder "%s" ', oldDerivedPathRel);
                    if pathscompare(obj.derivedPathBidsCompliant, obj.outputDirname, 'nameonly')
                        msg{2} = sprintf('The current derived output folder, "%s", is BIDS compliant. ', ...
                            filesepStandard(obj.derivedPathBidsCompliant, 'filesepwide:nameonly'));
                    else
                        msg{2} = '.';
                    end
                    msg = [msg{:}];
                    obj.logger.Write('Backward Compatability:   %s\n', msg);
                    
                    % If we're here it means that old format homer3 data exists
                    % AND NO new homer3 format data exists
                    q = MenuBox(sprintf('%s Do you want to move %s to the new folder?', msg, oldDerivedPathRel),{'Yes','No'});
                    if q==1
                        if ispathvalid([obj.path, obj.outputDirname])
                            try
                                rmdir([obj.path, obj.outputDirname], 's')
                            catch
                                MenuBox(sprintf('ERROR:  Could not remove new derived folder'),{'OK'});
                                return
                            end
                        end
                        obj.logger.Write('Moving %s to %s\n', oldDerivedPath, [obj.path, obj.outputDirname]);
                        movefile(oldDerivedPath, [obj.path, obj.outputDirname])
                        
                        if ispathvalid([obj.path, obj.outputDirname, obj.outputFilename])
                            if ~strcmp(obj.outputFilename, 'groupResults.mat')
                                obj.logger.Write('Moving %s to %s\n', [obj.path, obj.outputDirname, 'groupResults.mat'], ...
                                    [obj.path, obj.outputDirname, obj.outputFilename])
                                movefile([obj.path, obj.outputDirname, 'groupResults.mat'], [obj.path, obj.outputDirname, obj.outputFilename])
                            end
                        end
                    end
                    break
                end
                
            end            
        end
            
        
    end  % Private methods

end % classdef GroupClass < TreeNodeClass

