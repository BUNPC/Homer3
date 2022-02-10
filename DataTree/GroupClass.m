classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        version;
        versionStr;
        subjs;
    end
    
    properties % (Access = private)
        outputFilename
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = GroupClass(varargin)
            obj@TreeNodeClass(varargin);

            obj.InitVersion();

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
                obj.logger.Write(sprintf('%s\n', [msg{:}]));
            end
            
            % Add subject to this group
            jj=0;
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
                obj.logger.Write(sprintf('   Added subject %s to group %s.\n', obj.subjs(jj).GetName, obj.GetName));
            end
                        
            % Add sess to subj
            obj.subjs(jj).Add(sess, run);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function list = DepthFirstTraversalList(obj)
            list{1} = obj;
            for ii=1:length(obj.subjs)
                list = [list; obj.subjs(ii).DepthFirstTraversalList()];
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
            g = obj;
            s = obj.subjs(1);
            t = obj.subjs(1).sess(1);
            r = obj.subjs(1).sess(1).runs(1);
            for ii = 1:length(obj.subjs)
                if ~obj.subjs(ii).procStream.IsEmpty()
                    s = obj.subjs(ii);
                end
                for jj = 1:length(obj.subjs(ii).sess)
                    if ~obj.subjs(ii).sess(jj).procStream.IsEmpty()
                        t = obj.subjs(ii).sess(jj);
                    end
                    for kk = 1:length(obj.subjs(ii).sess)
                        if ~obj.subjs(ii).sess(jj).procStream.IsEmpty()
                            r = obj.subjs(ii).sess(kk).runs(kk);
                end
                    end
                end
            end
            
            % Generate procStream defaults at each level with which to initialize
            % any uninitialized procStream.input
            g.CreateProcStreamDefault();
            procStreamGroup = g.GetProcStreamDefault();
            procStreamSubj = s.GetProcStreamDefault();
            procStreamRun = r.GetProcStreamDefault();
            
            % If any of the tree nodes still have unintialized procStream input, ask 
            % user for a config file to load it from 
            if g.procStream.IsEmpty() || s.procStream.IsEmpty() || r.procStream.IsEmpty()
                [fname, autoGenDefaultFile] = g.procStream.GetConfigFileName(procStreamCfgFile, obj.path);                                
                
                % If user did not provide procStream config filename and file does not exist
                % then create a config file with the default contents
                if ~exist(fname, 'file')
                    procStreamGroup.SaveConfigFile(fname, 'group');
                    procStreamSubj.SaveConfigFile(fname, 'subj');
                    procStreamRun.SaveConfigFile(fname, 'run');
                end
                
                obj.logger.Write(sprintf('Attempting to load proc stream from %s\n', fname));
                
                % Load file to the first empty procStream in the dataTree at each processing level
                g.LoadProcStreamConfigFile(fname);
                s.LoadProcStreamConfigFile(fname);
                r.LoadProcStreamConfigFile(fname);
                
                % Copy the loaded procStream at each processing level to all
                % nodes of that level that lack procStream 
                
                % If proc stream input is still empty it means the loaded config
                % did not have valid proc stream input. If that's the case we
                % Load a default proc stream input
                if g.procStream.IsEmpty() || s.procStream.IsEmpty() || r.procStream.IsEmpty()
                    obj.logger.Write(sprintf('Failed to load all function calls in proc stream config file. Loading default proc stream...\n'));
                    g.CopyFcalls(procStreamSubj, 'subj');
                    g.CopyFcalls(procStreamRun, 'run');
                    
                    % If user asked default config file to be generated ...
                    if autoGenDefaultFile
                        obj.logger.Write(sprintf('Generating default proc stream config file %s\n', fname));
                        
                        % Move exiting default config to same name with .bak extension
                        if ~exist([fname, '.bak'], 'file')
                            obj.logger.Write(sprintf('Moving existing %s to %s.bak\n', fname, fname));
                            movefile(fname, [fname, '.bak']);
                        end
                        procStreamGroup.SaveConfigFile(fname, 'group');
                        procStreamSubj.SaveConfigFile(fname, 'subj');
                        procStreamRun.SaveConfigFile(fname, 'run');
                    end
                    
                % Otherwise the non-default processing stream loaded from file to this group and to first subject 
                % disseminate it to all subjects and all runs in this group
                else                    
                    obj.logger.Write(sprintf('Loading proc stream from %s\n', fname));
                    g.CopyFcalls(s.procStream, 'subj');
                    g.CopyFcalls(r.procStream, 'run');
                end
            end
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
                obj.logger.Write(sprintf('Calculating processing stream for group %d\n', obj.iGroup))
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
                obj.logger.Write(sprintf('Completed processing stream for group %d\n', obj.iGroup));
                obj.logger.Write(sprintf('\n'));
            end
            
            % Update call application GUI using it's generic Update function
            if ~isempty(obj.updateParentGui)
                obj.updateParentGui('DataTreeClass', [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun]);
            end
            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            obj.logger.Write(sprintf('\n'));
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
                            obj.logger.Write(sprintf('Saved group data, version %s exists\n', g.group.GetVersionStr()));
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
                    obj.logger.Write(sprintf('Warning: This folder contains old version of processing results. Will move it to *_old.mat\n'));
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
            
            obj.logger.Write(sprintf('Saving processed data in %s\n', [obj.path, obj.outputDirname, obj.outputFilename]));
            
            if ishandle(hwait)
                obj.logger.Write(sprintf('Auto-saving processing results ...\n'), obj.logger.ProgressBar(), hwait);
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
        function ExportHRF(obj, procElemSelect, iBlk)
            if ~exist('procElemSelect','var') || isempty(procElemSelect)
                q = MenuBox('Export only current group data OR current group data and all it''s subject data?', ...
                            {'Current group data only','Current group data and all it''s subject data','Cancel'});
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
                for ii = 1:length(obj.subjs)
                    obj.subjs(ii).ExportHRF('all', iBlk);
                end
            end            
            obj.ExportHRF@TreeNodeClass(procElemSelect, iBlk);            
        end

        
        % ----------------------------------------------------------------------------------
        function tblcells = ExportMeanHRF(obj, trange, iBlk)
            if ~exist('trange','var') || isempty(trange)
                trange = [];
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
                        
            nCh   = obj.procStream.GetNumChForOneCondition(iBlk);
            nCond = length(obj.CondNames);
            nSubj = length(obj.subjs);
            
            % Determine table dimensions            
            nHdrRows = 3;               % Blank line + name of columns
            nHdrCols = 2;               % Condition name + subject name
            nDataRows = nSubj*nCond;    
            nDataCols = nCh;                 % Number of channels for one condition (for example, if data type is Hb Conc: (HbO + HbR + HbT) * num of SD pairs)
            nTblRows = nDataRows + nHdrRows;
            nTblCols = nDataCols + nHdrCols;
            cellwidthCond = max(length('Condition'), obj.CondNameSizeMax());
            cellwidthSubj = max(length('Subject Name'), obj.SubjNameSizeMax());
            
            %%%% Initialize 2D array of TableCell objects with the above row * column dimensions            
            tblcells = repmat(TableCell(), nTblRows, nTblCols);
            
            % Header row: Condition, Subject Name, HbO,1,1, HbR,1,1, HbT,1,1, ...
            tblcells(2,1) = TableCell('Condition', cellwidthCond);
            tblcells(2,2) = TableCell('Subject Name', cellwidthSubj);
            [tblcells(2,3:end), cellwidthData] = obj.procStream.GenerateTableCellsHeader_MeanHRF(iBlk);
            
            % Generate data rows
            for iSubj = 1:nSubj
                rowIdxStart = ((iSubj-1)*nCond)+1 + nHdrRows;
                rowIdxEnd   = rowIdxStart + nCond - 1;
                
                tblcells(rowIdxStart:rowIdxEnd, 1:2)        = obj.subjs(iSubj).GenerateTableCellsHeader_MeanHRF(cellwidthCond, cellwidthSubj);
                tblcells(rowIdxStart:rowIdxEnd, 3:nTblCols) = obj.subjs(iSubj).GenerateTableCells_MeanHRF(trange, cellwidthData, iBlk);
            end
            
            % Create ExportTable initialized with the filled in 2D TableCell array. 
            % ExportTable object is what actually does the exporting to a file. 
            ExportTable([obj.path, obj.outputDirname, obj.name], 'HRF mean', tblcells);
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
        function ch = GetMeasList(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk=1;
            end
            ch = obj.subjs(1).GetMeasList(iBlk);
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
            for ii=1:length(obj.subjs)
                obj.subjs(ii).RenameCondition(oldname, newname);
            end
        end

        
        
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
        function n = CondNameSizeMax(obj)
            n = 0;
            if isempty(obj.CondNames)
                return;
            end
            for ii = 1:length(obj.CondNames)
                if length(obj.CondNames{ii}) > n
                    n = length(obj.CondNames{ii});
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = SubjNameSizeMax(obj)
            n = 0;
            if isempty(obj.subjs)
                return;
            end
            for ii = 1:length(obj.subjs)
                if length(obj.subjs(ii).name) > n
                    n = length(obj.subjs(ii).name);
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = HaveOutput(obj)
            b = false;
            for ii = 1:length(obj.subjs)
                b = obj.subjs(ii).HaveOutput();
                if b
                    break;
                end
            end
        end
        
        
                
        % ----------------------------------------------------------------------------------
        function BackwardCompatability(obj)
            if ispathvalid([obj.path, 'groupResults.mat'])
                try
                    g = load([obj.path, 'groupResults.mat']);
                catch ME
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
                
                msg = sprintf('Detected derived data in an old Homer3 format.');
                obj.logger.Write(sprintf('Backward Compatability: %s\n', msg));
                
                % If we're here it means that old format homer3 data exists
                % AND NO new homer3 format data exists
                q = MenuBox(sprintf('%s. Do you want to save it in the new format?', msg),{'Yes','No'});
                if q==1
                    obj.BackwardCompatability@TreeNodeClass();
                    for ii = 1:length(obj.subjs)
                        obj.subjs(ii).BackwardCompatability();
                    end
                    
                    obj.logger.Write(sprintf('Moving %s to %s\n', 'groupResults.mat', [obj.path, obj.outputDirname, obj.outputFilename]));
                    movefile('groupResults.mat', [obj.path, obj.outputDirname, obj.outputFilename])
                end
            end
        end
            
    end  % Private methods

end % classdef GroupClass < TreeNodeClass

