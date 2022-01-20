classdef DataTreeClass <  handle
    
    properties
        files
        filesErr
        groups
        dirnameGroups
        currElem
        reg
        config
        logger
        warningflag
        dataStorageScheme
    end
    
    
    
    
    methods
        
        % ---------------------------------------------------------------
        function obj = DataTreeClass(groupDirs, fmt, procStreamCfgFile, options)
            global logger
            global cfg
            
            obj.groups              = GroupClass().empty();
            obj.currElem            = TreeNodeClass().empty();
            obj.reg                 = RegistriesClass().empty();
            obj.dirnameGroups       = {};
            obj.logger              = InitLogger(logger, 'DataTree');
            cfg                     = InitConfig(cfg);
            
            
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
            
            % Load user function registry
            obj.reg = RegistriesClass();
            if ~isempty(obj.reg.GetSavedRegistryPath())
                obj.logger.Write(sprintf('Loaded saved registry %s\n', obj.reg.GetSavedRegistryPath()));
            end
            
            % Initialize the current processing element within the group
            obj.SetCurrElem(1,1,1);
            
            obj.warningflag = 0;
            
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
            iG = idx(1);
            iS = idx(2);
            iR = idx(3);
            if isempty(obj.groups) 
                obj.groups = GroupClass(obj2.groups(iG));
            else
                obj.groups(iG).Copy(obj.groups(iG))
            end
            obj.SetCurrElem(iG, iS, iR);
            obj.groups(iG).SetConditions();
        end
        
        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            idx = obj2.currElem.GetIndexID();
            iG = idx(1);
            obj.groups(iG).CopyStims(obj2.groups(iG));            
        end
        
        
        % --------------------------------------------------------------
        function status = FoundDataFilesInOtherFormat(obj, dataInit, kk)            
            global supportedFormats
            status = false;
            k = [];

            format0 = dataInit.type;
            
            % Find index of another file format to try
            for ii = 1:length(supportedFormats)
                if ~isempty(findstr(dataInit.type, supportedFormats{ii,1})) %#ok<FSTR>
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
                if isempty(dataInit) || dataInit.isempty()
                    return;
                end
            else
                dataInit = [];
            end
            
            if ~isempty(dataInit)
                msg{1} = sprintf('Could not load any of the .%s files in the group folder but did find .%s files. ', format0, dataInit.type);
                msg{3} = sprintf('Do you want to rename the .%s files to names with a .old extension, delete them or cancel? ', format0);
                msg{2} = sprintf('NOTE: Renaming or deleting the .%s files will allow Homer3 to regenerate them from .%s file later.', ...
                    format0, dataInit.type);
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
        function status = SelectOptionsWhenLoadFails(obj)
            status = -1;
    
            %             msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroups);
            %             msg{2} = sprintf('Do you want to select another group folder?');
            %             q = MenuBox(msg, {'YES','NO'});
                        
            msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroups);
            msg{2} = sprintf('Do you want to select another group folder?');
            q = MenuBox(msg, {'YES','NO'}, [], 110);
            if q==2
                obj.logger.Write(sprintf('Skipping group folder %s...\n', obj.dirnameGroups));
                obj.dirnameGroups = 0;
                return;
            end
            obj.dirnameGroups = uigetdir(pwd, 'Please select another group folder ...');
            if obj.dirnameGroups==0
                obj.logger.Write(sprintf('Skipping group folder %s...\n', obj.dirnameGroups));
                return;
            end
            status = 0;
        end
        
        
        
        % --------------------------------------------------------------
        function FindAndLoadGroups(obj, groupDirs, fmt, procStreamCfgFile, options)

            tic;            
            for kk = 1:length(groupDirs)
                
                obj.dirnameGroups{kk} = filesepStandard(groupDirs{kk},'full');

                iGnew = length(obj.groups)+1;
                               
                % Get file names and load them into DataTree
                while length(obj.groups) < iGnew
                    
                    obj.logger.Write('\n');
                    
                    % Find group folder and it's acqiosition files                    
                    obj.files    = FileClass().empty();
                    obj.filesErr = FileClass().empty();
                    dataInit     = DataFilesClass();
                    dataInitPrev = DataFilesClass();
                    iter = 1;
                    while dataInit.GetError() < 0
                        dataInit = FindFiles(obj.dirnameGroups{kk}, fmt, options);
                        if isempty(dataInit) || dataInit.isempty()
                            return;
                        end
                        dataInitPrev(iter) = dataInit;
                        obj.dirnameGroups{kk} = dataInit.pathnm;
                        iter = iter+1;
                    end                    
                    obj.files = dataInit.files;

                    obj.logger.Write('\n');

                    % Print file and folder numbers stats
                    nfolders = length(dataInit.files)-dataInit.nfiles;
                    if nfolders==0
                        nfolders = 1;
                    end
                    obj.logger.Write(sprintf('DataTreeClass.FindAndLoadGroups: Found %d data files in %d folders\n', ...
                            dataInit.nfiles, nfolders));
                    
                    % Now load group files to data tree
                    obj.LoadGroup(iGnew, procStreamCfgFile, options);
                    if length(obj.groups) < iGnew
                        if obj.FoundDataFilesInOtherFormat(dataInit, kk)
                            continue;
                        elseif obj.SelectOptionsWhenLoadFails()<0
                            break;
                        end
                    end
                    
                    % Clean up any obsolete files in output folder if names
                    % of files or folder was changed
                    obj.groups(iGnew).CleanUpOutput(dataInitPrev);
                                        
                end
                
            end
            obj.logger.Write(sprintf('Loaded data set in %0.1f seconds\n', toc));
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
            % obj.logger.Write(sprintf('Memory required for data tree: %0.1f MB\n', obj.MemoryRequired() / 1e6));            
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
        function LoadGroup(obj, iG, procStreamCfgFile, options)
            
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            if ~exist('options','var')
                options = '';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load acquisition data from the data files
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AcqData2Group(iG);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Remove file entries from files array for data files 
            % which didn't load correctly because of format incompatibility
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.ErrorCheckLoadedFiles();

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load derived or post-acquisition data from a file if it
            % exists
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iG).Load('init');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize procStream for all tree nodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~optionExists(options, 'noloadconfig')
            	obj.groups(iG).InitProcStream(procStreamCfgFile);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Generate the stimulus conditions for the group tree
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.groups(iG).SetConditions();

        end
        
        
        % ----------------------------------------------------------
        function AcqData2Group(obj, iG)
            if isempty(obj.files)
                return;
            end
            if ~exist('iG','var')
                iG = 1;
            end
            groupCurr = GroupClass().empty();
            subjCurr = SubjClass().empty();
            runCurr = RunClass().empty();

            tic;            
            obj.logger.Write(sprintf('\n'));
            for iF = 1:length(obj.files)

                % Extract group, subj, and run names from file struct
                [groupName, subjName, runName] = obj.files(iF).ExtractNames();

                % Create current TreeNode objects corresponding to the current files entry
                if ~isempty(groupName) && ~strcmp(groupName, groupCurr.GetName)
                    groupCurr = GroupClass(obj.files(iF), iG, 'noprint');
                end
                if ~isempty(subjName) && ~strcmp(subjName, subjCurr.GetName)
                    subjCurr = SubjClass(obj.files(iF));
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
                    obj.Add(groupCurr, subjCurr, runCurr);
                    runCurr = RunClass().empty();
                end
            end
            obj.logger.Write(sprintf('\n'));
            obj.logger.Write(sprintf('Loaded group %s acquisition data in %0.1f seconds\n', obj.groups(iG).name, toc));
            obj.logger.Write(sprintf('  Derived data output folder   : %s%s\n', obj.groups(iG).path, obj.groups(iG).outputDirname));
            obj.logger.Write(sprintf('  Derived data output file     : %s\n\n', obj.groups(iG).outputFilename));
            
        end


       
        % ----------------------------------------------------------
        function Add(obj, group, subj, run)
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
                obj.logger.Write(sprintf('Added group %s to dataTree.\n', obj.groups(jj).GetName));
            end

            %v Add subj and run to group
            obj.groups(jj).Add(subj, run);            
        end

        
        % ----------------------------------------------------------
        function ErrorCheckLoadedFiles(obj)
            for iF=length(obj.files):-1:1
                if ~obj.files(iF).Loadable() && obj.files(iF).IsFile()
                    obj.filesErr(end+1) = obj.files(iF).copy;
                    obj.files(iF) = [];
                end                    
            end
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
            err = obj.currElem.Load();
        end


        % ----------------------------------------------------------
        function SetCurrElem(obj, iGroup, iSubj, iRun)
            if isempty(obj.groups)
                return;
            end
            
            if nargin==1
                iGroup = 0;
                iSubj = 0;
                iRun  = 0;
            elseif nargin==2
                iSubj = 0;
                iRun  = 0;
            elseif nargin==3
                iRun  = 0;
            end

            if obj.currElem.IsSame(iGroup, iSubj, iRun)
                return;
            end
            
            % Free up memory of current element before reassigning it to
            % another node. 
            obj.currElem.FreeMemory();
            
            if iSubj==0 && iRun==0
                obj.currElem = obj.groups(iGroup);
            elseif iSubj>0 && iRun==0
                obj.currElem = obj.groups(iGroup).subjs(iSubj);
            elseif iSubj>0 && iRun>0
                obj.currElem = obj.groups(iGroup).subjs(iSubj).runs(iRun);
            end
        end


        % ----------------------------------------------------------
        function procElem = GetCurrElem(obj)
            procElem = obj.currElem;
        end


        % ----------------------------------------------------------
        function [iGroup, iSubj, iRun] = GetCurrElemIndexID(obj)
            iGroup = obj.currElem.iGroup;
            iSubj = obj.currElem.iSubj;
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
            iRun   = idx(3);
                                    
            if iSubj==0 && iRun==0
                obj.currElem = obj3.groups(iGroup);
            elseif iSubj>0 && iRun==0
                obj.currElem = obj3.groups(iGroup).subjs(iSubj);
            elseif iSubj>0 && iRun>0
                obj.currElem = obj3.groups(iGroup).subjs(iSubj).runs(iRun);
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
        
        
        
        % ----------------------------------------------------------------------------------
        function diskspaceToSpare = CheckAvailableDiskSpace(obj, hwait)
            diskspaceToSpare = getFreeDiskSpace();   % Disk space to spare in megabytes
            %diskspaceToSpare = (getFreeDiskSpace() - obj.MemoryRequired());   % Disk space to spare in megabytes
        end

        
        
        % ----------------------------------------------------------
        function Save(obj, hwait)
            if ~exist('hwait','var')
                hwait = [];
            end
            
            % Check that there is anough disk space. NOTE: for now we
            % assume that all groups are on the same drive. This should be 
            % changed but for now we simplify. 
            if obj.CheckAvailableDiskSpace(hwait) <= 0
                return;
            end
            
            t_local = tic;
            for ii = 1:length(obj.groups)
                obj.logger.Write(sprintf('Saving group %d in %s\n', ii, [obj.groups(ii).pathOutputAlt, obj.groups(ii).GetFilename()]));
                obj.groups(ii).Save(hwait);
            end
            obj.logger.Write(sprintf('Completed saving processing results for all groups in %0.3f seconds.\n', toc(t_local)));
        end


        % ----------------------------------------------------------
        function CalcCurrElem(obj)
            obj.currElem.Calc();
        end

        
        % ----------------------------------------------------------
        function ResetCurrElem(obj)
            obj.currElem.Reset();
            idx = obj.currElem.GetIndexID();
            if isa(obj.currElem, 'SubjClass')
                obj.groups(idx(1)).Reset('up')
            elseif isa(obj.currElem, 'RunClass')
                obj.groups(idx(1)).Reset('up')
                obj.groups(idx(1)).subjs(idx(2)).Reset('up')
            end
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

    end
    
end