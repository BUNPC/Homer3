classdef DataTreeClass <  handle
    
    properties
        files
        filesErr
        groups
        dirnameGroups
        currElem
        reg
        logger
        cfg
        warningflag
        dataStorageScheme
        warnings
        errorStats
    end
    
    
    
    
    methods
        
        % ---------------------------------------------------------------
        function obj = DataTreeClass(groupDirs, fmt, procStreamCfgFile, options)
            global logger
            global cfg
                       
            obj.InitNamespace();
            
            logger                  = InitLogger(logger, 'DataTreeClass');
            cfg                     = InitConfig(cfg);

            obj.logger              = logger;
            obj.cfg                 = cfg;
            
            obj.groups              = GroupClass().empty();
            obj.currElem            = TreeNodeClass().empty();
            obj.reg                 = RegistriesClass().empty();
            obj.dirnameGroups       = {};
            obj.warnings            = '';
            obj.errorStats        = [0,0,0];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Announce who we are and our version number
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            logger.Write('DataTreeClass:  v%s\n', getVernum('DataTreeClass'));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Parse args
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Arg 1: get folder of the group being loaded
            if ~exist('groupDirs','var') || isempty(groupDirs)
                groupDirs{1} = pwd;
            elseif ~isa(groupDirs, 'DataTreeClass') && ~iscell(groupDirs)
                groupDirs = {groupDirs};
            end
            
            % Arg 2: get the file format of the data files
            if ~exist('fmt','var')
                fmt = '';
            end
            
            % Arg 3: Get the processing stream config files name
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            
            % Arg 4: Force distrubited file saving scheme
            if ~exist('options','var')
                options = '';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Now that we have all the arguments, ready to start
            % condtructing object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(groupDirs, 'DataTreeClass')
               obj.Copy(groupDirs);
               return;
            elseif strcmp(options, 'empty')
                return;
            end
            
            obj.dataStorageScheme = cfg.GetValue('Data Storage Scheme');

            % Estimate amount of memory required and set the data storage scheme
            obj.SetDataStorageScheme();
            
            % Load user function registry
            obj.reg = RegistriesClass();
            if ~isempty(obj.reg.GetSavedRegistryPath())
                obj.logger.Write('Loaded saved registry %s\n', obj.reg.GetSavedRegistryPath());
            end

            % Load data
            obj.FindAndLoadGroups(groupDirs, fmt, procStreamCfgFile, options);
            if obj.IsEmpty()
                return;
            end
            
            % Change current folder to last loaded group; even though we
            % handle multiple groups and use absolute paths we still have
            % group as the basic data unit and context. So we want to 
            % change the current folder to whatever is the current working
            % group.
            cd(obj.groups(end).path);
            
            % Initialize the current processing element within the group
            obj.SetCurrElem(1,1,1,1);
            
            obj.warningflag = 0;
            
        end
        
        
        
        % --------------------------------------------------------------
        function InitNamespace(obj)
            nm = getNamespace();
            if isempty(nm)
                setNamespace('DataTreeClass');
            end
        end
        
        
        
        % --------------------------------------------------------------
        function delete(obj)
            if isa(obj.logger, 'Logger')
                obj.logger.Close('DataTree');
            end
        end
        
        
        % --------------------------------------------------------------
        function Copy(obj, obj2)
            idx = obj2.currElem.GetIndexID();
            iGroup = idx(1);
            iSubj = idx(2);
            iSess = idx(3);
            iRun = idx(4);
            if isempty(obj.groups) 
                obj.groups = GroupClass(obj2.groups(iGroup));
            else
                obj.groups(iGroup).Copy(obj.groups(iGroup))
            end
            obj.SetCurrElem(iGroup, iSubj, iSess, iRun);
            obj.groups(iGroup).SetConditions();
            obj.dataStorageScheme = obj2.dataStorageScheme;
        end
        
        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            idx = obj2.currElem.GetIndexID();
            iGroup = idx(1);
            obj.groups(iGroup).CopyStims(obj2.groups(iGroup));            
        end
        
        
        % --------------------------------------------------------------
        function status = FoundDataFilesInOtherFormat(obj, dataInit, kk)            
            global supportedFormats
            status = false;
            k = [];

            format0 = dataInit.filetype;
            
            % Find index of another file format to try
            for ii = 1:length(supportedFormats)
                if ~isempty(findstr(dataInit.filetype, supportedFormats{ii,1})) %#ok<FSTR>
                   k = ii;
                   break;
                end
            end
            if isempty(k)
                return;
            end
            if k<length(supportedFormats) && k>1
                k = k-1;
            elseif k<length(supportedFormats)
                k = k+1;
            else
                k = [];
            end
            if ~isempty(k)
                dataInit = FindFiles(obj.dirnameGroups{kk}, supportedFormats{k});
                if isempty(dataInit) || dataInit.IsEmpty()
                    return;
                end
            else
                dataInit = [];
            end
            
            if ~isempty(dataInit)
                msg{1} = sprintf('Could not load any of the .%s files in the group folder but did find .%s files. ', format0, dataInit.filetype);
                msg{3} = sprintf('Do you want to rename the .%s files to names with a .old extension, delete them or cancel? ', format0);
                msg{2} = sprintf('NOTE: Renaming or deleting the .%s files will allow Homer3 to regenerate them from .%s file later.', ...
                    format0, dataInit.filetype);
                q = MenuBox(msg, {'Rename (Recommended)','Delete','CANCEL'}, [], 90);
                if q==1
                    DeleteDataFiles(obj.dirnameGroups, format0, 'move')
                    status = true;
                elseif q==2
                    DeleteDataFiles(obj.dirnameGroups, format0)
                    status = true;
                end
            end            
        end

        
        
        % --------------------------------------------------------------
        function status = SelectOptionsWhenLoadFails(obj, iGroup)
            status = -1;
    
            %             msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroups);
            %             msg{2} = sprintf('Do you want to select another group folder?');
            %             q = MenuBox(msg, {'YES','NO'});
                        
            if iGroup > length(obj.dirnameGroups)
                return;
            end
                
            msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroups{iGroup});
            msg{2} = sprintf('Do you want to select another group folder?');
            q = MenuBox(msg, {'YES','NO'}, [], 110);
            if q==2
                obj.logger.Write('Skipping group folder %s...\n', obj.dirnameGroups{iGroup});
                obj.dirnameGroups = 0;
                return;
            end
            obj.dirnameGroups = uigetdir(pwd, 'Please select another group folder ...');
            if obj.dirnameGroups==0
                obj.logger.Write('Skipping group folder %s...\n', obj.dirnameGroups{iGroup});
                return;
            end
            status = 0;
        end
        
        
        
        % --------------------------------------------------------------
        function FindAndLoadGroups(obj, groupDirs, fmt, procStreamCfgFile, options)

            t1 = tic;            
            for kk = 1:length(groupDirs)
                
                obj.dirnameGroups{kk} = filesepStandard(groupDirs{kk},'full');

                iGroupNew = length(obj.groups)+1;
                               
                % Get file names and load them into DataTree
                while length(obj.groups) < iGroupNew
                    
                    obj.logger.Write('\n');
                    obj.logger.Write('DataTreeClass.FindAndLoadGroups:    Searching for data files. Please wait ...\n\n');
                    
                    % Find group folder and it's acqiosition files                    
                    obj.files    = FileClass().empty();
                    obj.filesErr = FileClass().empty();
                    dataInit     = DataFilesClass();
                    dataInitPrev = DataFilesClass();
                    iter = 1;
                    while dataInit.GetError() < 0
                        dataInit = FindFiles(obj.dirnameGroups{kk}, fmt, options);
                        if isempty(dataInit) || dataInit.IsEmpty()
                            return;
                        end
                        dataInitPrev(iter) = dataInit;
                        obj.dirnameGroups{kk} = dataInit.rootdir;
                        iter = iter+1;
                    end                    
                    obj.files = dataInit.files;
                    obj.filesErr = dataInit.filesErr;

                    obj.PrintDatasetFormat(dataInit);
                    
                    % Now load group files to data tree
                    obj.LoadGroup(iGroupNew, procStreamCfgFile, options);
                    if length(obj.groups) < iGroupNew
                        if obj.FoundDataFilesInOtherFormat(dataInit, kk)
                            continue;
                        elseif obj.SelectOptionsWhenLoadFails(iGroupNew)<0
                            break;
                        end
                    end
                    
                    % Clean up any obsolete files in output folder if names
                    % of files or folder was changed
                    obj.groups(iGroupNew).CleanUpOutput(dataInitPrev);
                                        
                end
                
            end
            
            obj.PrintProcStream();
            
            obj.logger.Write('Loaded data set in %0.1f seconds\n', toc(t1));
        end
        
        

        % ---------------------------------------------------------------
        function PrintProcStream(obj, banner)
            if ~exist('banner','var')
                banner = '';
            end
            obj.logger.Write('\n');
            if ~isempty(banner)
                obj.logger.Write('\n');
                obj.logger.Write('!! ******** START  %s', banner);
                obj.logger.Write('\n');
            end
            obj.groups(1).PrintProcStream();
            if ~isempty(banner)
                obj.logger.Write('\n');
                obj.logger.Write('!! ******** END  %s\n', banner);
                obj.logger.Write('\n');
            end
            obj.logger.Write('\n');
        end
        
            
            
        % ---------------------------------------------------------------
        function SetDataStorageScheme(obj)

            % If there is no config option that was used to set
            % dataStorageScheme then try to determine from saved data 
            % what the storage scheme is. Main user of this is AtlasViewer            
            if isempty(obj.dataStorageScheme)
                obj.AutoSetDataStorageScheme();
            end
            
            % Estimate memory requirement based on number of acquired files and their
            % average size
            % obj.logger.Write('Memory required for data tree: %0.1f MB\n', obj.MemoryRequired() / 1e6));            
            if strcmpi(obj.dataStorageScheme, 'files') || strcmpi(obj.dataStorageScheme, 'disk')
                onoff = true;
            elseif strcmpi(obj.dataStorageScheme, 'memory') || strcmpi(obj.dataStorageScheme, 'ram')
                onoff = false;
            else
                onoff = false;
            end
            obj.groups.SaveMemorySpace(onoff);            
        end 
        
          
        
        % ---------------------------------------------------------------
        function AutoSetDataStorageScheme(obj)
            if isempty(obj.dataStorageScheme)
                obj.dataStorageScheme = 'files';
            end
        end
          
        
        
        % ---------------------------------------------------------------
        function LoadGroup(obj, iGroup, procStreamCfgFile, options)
            
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            if ~exist('options','var')
                options = '';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load acquisition data from the data files
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AcqData2Group(iGroup);
            if isempty(obj.groups)
                return
            end
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Remove file entries from files array for data files 
            % which didn't load correctly because of format incompatibility
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.ErrorCheckLoadedFiles();

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Export stim to TSV files 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [stimExport, stimExportOptions] = obj.AutoExportStim();
            if stimExport
                obj.groups(iGroup).ExportStim(stimExportOptions)
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load dataTree group structure from file. Not that this 
            % might not include processed output if storage scheme 
            % is 'file' instead of 'memory'.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iGroup).Load('init');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize procStream for all tree nodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iGroup).InitProcStream(procStreamCfgFile, options);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Generate the stimulus conditions for the group tree
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iGroup).SetConditions();

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Save
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iGroup).Save();

        end
        
        
        % ----------------------------------------------------------
        function AcqData2Group(obj, iGroup)
            if isempty(obj.files)
                return;
            end
            if ~exist('iGroup','var')
                iGroup = 1;
            end
            groupCurr = GroupClass().empty();
            subjCurr = SubjClass().empty();
            sessCurr  = SessClass().empty();
            runCurr = RunClass().empty();

            t1 = tic;
            obj.logger.Write('\n');
            for iF = 1:length(obj.files)

                % Extract group, subj, and run names from file struct
                [groupName, subjName, sessName, runName] = obj.files(iF).ExtractNames();

                % Create current TreeNode objects corresponding to the current files entry
                if ~isempty(groupName) && ~strcmp(groupName, groupCurr.GetName)
                    groupCurr = GroupClass(obj.files(iF), iGroup, 'noprint');
                end
                if ~isempty(subjName) && ~strcmp(subjName, subjCurr.GetName)
                    subjCurr = SubjClass(obj.files(iF));
                end
                if ~isempty(sessName) && ~strcmp(sessName, sessCurr.GetName)
                    sessCurr = SessClass(obj.files(iF));
                end
                if ~isempty(runName) && ~strcmp(runName, runCurr.GetName)
                    runCurr = RunClass(obj.files(iF));
                end

                % If current run has successfully loaded acquired data from data file, then add 
                % current group, subject and run to dataTree. Then reset current run to empty. 
                % (We do not reset current subject or group because they can contain multiple 
                % nodes and they cannot be empty once they've been initialized once whereas run 
                % can be if it fails to load a data file. 
                if ~runCurr.Error()
                    obj.Add(groupCurr, subjCurr, sessCurr, runCurr);
                    runCurr = RunClass().empty();
                end
            end
            obj.logger.Write('\n');
            
            if ~isempty(obj.groups)
                obj.logger.Write('Loaded group %s acquisition data in %0.1f seconds\n', obj.groups(iGroup).name, toc(t1));
                obj.logger.Write('  Derived data output folder   : %s%s\n', obj.groups(iGroup).path, obj.groups(iGroup).outputDirname);
                obj.logger.Write('  Derived data output file     : %s\n\n', obj.groups(iGroup).outputFilename);
            else
                obj.logger.Write('No acquisition data to load\n');                
            end
            
        end


        
        % ----------------------------------------------------------
        function [exportStim, options] = AutoExportStim(obj)
            global cfg 
            v1 = cfg.GetValue('Export Stim To TSV File');
            v2 = cfg.GetValue('Export Stim To TSV File Regenerate');            
            exportStim = false;
            options = '';
            if strcmpi(v1, 'yes')
                exportStim = true;
            end
            if strcmpi(v1, 'Yes_Delete_Old')
                exportStim = true;
                options = 'removeStim';
            end
            if strcmpi(v2, 'yes')
                if isempty(options)
                    options = 'regenerate';
                else
                    options = [options, ':regenerate'];
                end
            end
        end
        
        
        
        
        % ----------------------------------------------------------------------------------
        function ReloadStim(obj)
            obj.currElem.ReloadStim();
            obj.SetConditions();
        end
                
        
       
        % ----------------------------------------------------------
        function Add(obj, group, subj, sess, run)
            if nargin<2
                return;
            end
                        
            % Add group to this dataTree
            jj=0;
            for ii=1:length(obj.groups)
                if strcmp(obj.groups(ii).GetName, group.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.groups)+1;
                group.SetIndexID(jj);
                obj.groups(jj) = group;
                obj.groups(jj).SetPath(obj.dirnameGroups{jj})
                obj.logger.Write('Added group  "%s"  to dataTree.\n', obj.groups(jj).GetName);
            end

            % Add subj, sess and run to group
            obj.groups(jj).Add(subj, sess, run);            
        end

        
        
        % ----------------------------------------------------------
        function idx = FindProcElem(obj, name)
            idx = [];
            for ii = 1:length(obj.groups)
                if strcmp(name, obj.groups(ii).GetName())
                    idx = obj.groups(ii).GetIndexID();
                    break;
                end
                if strcmp(name, obj.groups(ii).GetFilename())
                    idx = obj.groups(ii).GetIndexID();
                    break;
                end
                idx = obj.groups(ii).FindProcElem(name);
                if ~isempty(idx)
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------
        function CondNames = GetConditions(obj)
             iG = obj.GetCurrElem().iGroup;
             CondNames = obj.groups(iG).GetConditions();
        end
        
        
        % ----------------------------------------------------------
        function ErrorCheckLoadedFiles(obj)
            maxWarningsDisplay = 25;
            for iF = 1:length(obj.files)
                if ~isempty(obj.files(iF).GetErrorMsg())
                    if obj.errorStats(2) > maxWarningsDisplay
                        continue
                    end
                    if isempty(obj.warnings)
                        obj.warnings = sprintf('%s:   %s\n\n', obj.files(iF).name, obj.files(iF).GetErrorMsg());
                    elseif obj.errorStats(2) < maxWarningsDisplay-1
                        obj.warnings = sprintf('%s%s:   %s\n\n', obj.warnings, obj.files(iF).name, obj.files(iF).GetErrorMsg());
                    elseif obj.errorStats(2) == maxWarningsDisplay-1
                        obj.warnings = sprintf('%s  . . . Reached maximum number of warnings to display\n\n', obj.warnings);                        
                    end
                    if obj.files(iF).IsFile()
                        obj.errorStats(2) = obj.errorStats(2)+1;
                    end
                else
                    if obj.files(iF).IsFile()
                        obj.errorStats(1) = obj.errorStats(1)+1;
                    end
                end
            end
            obj.errorStats(3) = length(obj.filesErr);

            if isempty(obj.filesErr)
                return
            end
            obj.logger.Write('\n')
            obj.logger.Write('DataTreeClass.ErrorCheckLoadedFiles:   WARNING - The following files in this data set were NOT loaded:\n')
            for iF = 1:length(obj.filesErr)
                obj.logger.Write('   %s\n', obj.filesErr(iF).name)
            end
            obj.logger.Write('\n')
        end
        
        
        % ----------------------------------------------------------
        function w = GetWarningsReport(obj)
            [nFileSuccess, nFilesWarning, nFilesFailed] = obj.GetErrorStats();
            if ~isempty(obj.warnings)
                obj.warnings = sprintf('The following %d files were loaded with warnings:\n=========================================\n%s', nFilesWarning, obj.warnings);
            end
            w = obj.warnings;
        end
        
        
        % ----------------------------------------------------------
        function [nFileSuccess, nFilesWarning, nFilesFailed] = GetErrorStats(obj)
            nFileSuccess = obj.errorStats(1);
            nFilesWarning = obj.errorStats(2);
            nFilesFailed = obj.errorStats(3);
        end
        
        
        % ----------------------------------------------------------------------------------
        function list = DepthFirstTraversalList(obj)
            list = {};
            for ii=1:length(obj.groups)
                list = [list; obj.groups(ii).DepthFirstTraversalList()];
            end
        end        
        
        
        % ----------------------------------------------------------
        function err = LoadCurrElem(obj)
            err = 0;
            if isempty(obj.groups)
                return;
            end
            changeflag = false;
            if obj.currElem.AcquiredDataModified()
                changeflag = true;
            end
            
            err = obj.currElem.Load();
            
            % Check if stims were edited for current element in any way by checking if acquired data was modified. 
            % If current element stims were edited then re
            if changeflag
                obj.currElem.CopyStimAcquired();
                obj.SetConditions();
            end
        end


        % ----------------------------------------------------------
        function SetCurrElem(obj, iGroup, iSubj, iSess, iRun)
            if isempty(obj.groups)
                return;
            end
            
            if nargin==1
                iGroup = 0;
                iSubj = 0;
                iSess = 0;
                iRun  = 0;
            elseif nargin==2
                iSubj = 0;
                iSess = 0;
                iRun  = 0;
            elseif nargin==3
                iSess = 0;
                iRun  = 0;
            elseif nargin==4
                iRun  = 0;
            end

            if obj.currElem.IsSame(iGroup, iSubj, iSess, iRun)
                return;
            end
            
            % Free up memory of current element before reassigning it to
            % another node. 
            if strcmp(obj.dataStorageScheme, 'files')
                obj.currElem.FreeMemory();
            end
            
            if     iSubj==0 && iSess==0 && iRun==0
                obj.currElem = obj.groups(iGroup);
            elseif iSubj>0  && iSess==0 && iRun==0
                obj.currElem = obj.groups(iGroup).subjs(iSubj);
            elseif iSubj>0  && iSess>0 && iRun==0
                obj.currElem = obj.groups(iGroup).subjs(iSubj).sess(iSess);
            elseif iSubj>0  && iSess>0 && iRun>0
                obj.currElem = obj.groups(iGroup).subjs(iSubj).sess(iSess).runs(iRun);
            end
        end


        % ----------------------------------------------------------
        function procElem = GetCurrElem(obj)
            procElem = obj.currElem;
        end


        % ----------------------------------------------------------
        function [iGroup, iSubj, iSess, iRun] = GetCurrElemIndexID(obj)
            iGroup = obj.currElem.iGroup;
            iSubj = obj.currElem.iSubj;
            iSess = obj.currElem.iSess;
            iRun = obj.currElem.iRun;
        end


        % ----------------------------------------------------------
        function CopyCurrElem(obj, obj2, options)
            if isempty(obj)
                return;
            end
            if isempty(obj2)
                return;
            end
            if ~exist('options', 'var')
                options = 'reference';
            end
            
            if optionExists(options, 'reference')
                obj3 = obj2;
            elseif optionExists(options, 'value')
                obj3 = obj;
            end
            
            idx = obj2.currElem.GetIndexID();
            iGroup = idx(1);
            iSubj  = idx(2);
            iSess  = idx(3);
            iRun   = idx(4);
                                    
            if     iSubj==0 && iSess==0 && iRun==0
                obj.currElem = obj3.groups(iGroup);
            elseif iSubj>0  && iSess==0 && iRun==0
                obj.currElem = obj3.groups(iGroup).subjs(iSubj);
            elseif iSubj>0  && iSess>0 && iRun==0
                obj.currElem = obj3.groups(iGroup).subjs(iSubj).sess(iSess);
            elseif iSubj>0 && iSess>0 && iRun>0
                obj.currElem = obj3.groups(iGroup).subjs(iSubj).sess(iSess).runs(iRun);
            end
        end



        % ----------------------------------------------------------
        function SetConditions(obj)
            for ii = 1:length(obj.groups)
                obj.groups(ii).SetConditions();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return;
            end                        
            for ii = 1:length(obj.groups)
                nbytes = nbytes + obj.groups(ii).MemoryRequired();
            end
        end
        
        
        
        % ----------------------------------------------------------
        function Save(obj, hwait)           
            % Check that there is anough disk space. NOTE: for now we
            % assume that all groups are on the same drive. This should be 
            % changed but for now we simplify. 
            if getFreeDiskSpace() <= 0
                return;
            end
            
            if nargin==1
                hwait = waitbar_improved(0,  'Saving groups. Please wait ...');
            end
            
            t1 = tic;
            for ii = 1:length(obj.groups)
                obj.logger.Write('Saving group %d in %s\n', ii, [obj.groups(ii).pathOutputAlt, obj.groups(ii).GetFilename()]);
                obj.groups(ii).Save(hwait);
            end
            obj.logger.Write('Completed saving processing results for all groups in %0.3f seconds.\n', toc(t1));
            
            if nargin==1
                close(hwait);
            end
        end


        % ----------------------------------------------------------
        function CalcCurrElem(obj)
            banner = sprintf('Calculating derived data at %s with the following processing stream:\n\n', char(datetime(datetime, 'Format','HH:mm:ss, MMMM d, yyyy')));
            obj.PrintProcStream(banner);
            obj.currElem.Calc();
            obj.currElem.ExportProcStreamFunctions();
        end

        
        % ----------------------------------------------------------
        function ResetCurrElem(obj)
            obj.currElem.Reset();
        end
        
        
        % ----------------------------------------------------------
        function ResetAllGroups(obj)
            for ii = 1:length(obj.groups)
                obj.groups(ii).Reset()
            end
        end
        
        
        % ----------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return
            end
            if isempty(obj.files)
                return;
            end
            if isempty(obj.groups)
                return;
            end
            b = false;
        end
        
        
        
        % ----------------------------------------------------------
        function b = IsEmptyOutput(obj)
            b = true;
            if obj.IsEmpty()
                return;
            end
            for ii = 1:length(obj.groups)
                if ~obj.groups(ii).IsEmptyOutput
                    b = false;
                    break;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------
        function b = IsFlatFileDir(obj)
            if obj.files(1).isdir
                b = false;
            else
                b = true;
            end
        end

        
        % -----------------------------------------------------------
        function PrintDatasetFormat(obj, dataInit)
            
            % Print file and folder numbers stats
            nfolders = length(dataInit.files)-dataInit.nfiles;
            if nfolders==0
                nfolders = 1;
            end
            numFilesMsg = sprintf('%d data files in %d folders\n', dataInit.nfiles, nfolders);
            obj.logger.Write('\n');
            if dataInit.nfiles == 0
                obj.logger.Write('DataTreeClass.PrintDatasetFormat:   Did not find any data0 files %s.\n', numFilesMsg);
            elseif dataInit.dirFormats.type > 3 && dataInit.dirFormats.type < 9
                obj.logger.Write('DataTreeClass.PrintDatasetFormat:   Found BIDS data set (format #%d) with %s files.\n', dataInit.dirFormats.type, numFilesMsg);
            elseif dataInit.dirFormats.type < 4
                obj.logger.Write('DataTreeClass.PrintDatasetFormat:   Found non-standard data set (format #%d)  with %s files.\n', dataInit.dirFormats.type, numFilesMsg);
            elseif dataInit.dirFormats.type > 8
                obj.logger.Write('DataTreeClass.PrintDatasetFormat:   Found non-standard but BIDS-like data set (format #%d) with %s files.\n', dataInit.dirFormats.type, numFilesMsg);
            end
            obj.logger.Write('\n');
        end
            

        
        % --------------------------------------------------------------------------
        function ApplyParamEditsToAll(obj, iFcall, iParam, val)
            for iG = 1:length(obj.groups)                
                if     obj.currElem.iSubj>0  && obj.currElem.iSess==0 && obj.currElem.iRun==0
                    obj.groups(iG).ApplyParamEditsToAllSubjects(iFcall, iParam, val);
                elseif obj.currElem.iSubj>0  && obj.currElem.iSess>0 && obj.currElem.iRun==0
                    obj.groups(iG).ApplyParamEditsToAllSessions(iFcall, iParam, val);
                elseif obj.currElem.iSubj>0  && obj.currElem.iSess>0 && obj.currElem.iRun>0
                    obj.groups(iG).ApplyParamEditsToAllRuns(iFcall, iParam, val);
                end
            end
        end
        
        
    end
    
end