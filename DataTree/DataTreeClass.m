classdef DataTreeClass <  handle
    
    properties
        files
        filesErr
        groups
        dirnameGroup
        currElem
        reg
        config
        logger
        warningflag        
    end
    
    methods
        
        % ---------------------------------------------------------------
        function obj = DataTreeClass(groupDirs, fmt, procStreamCfgFile)
            global logger
            
            obj.groups        = GroupClass().empty();
            obj.currElem      = TreeNodeClass().empty();
            obj.reg           = RegistriesClass().empty();
            obj.config        = ConfigFileClass().empty();
            obj.dirnameGroup  = '';
            obj.logger        = InitLogger(logger, 'DataTree');
            
            
            %%%% Parse args
            
            % Arg 1: get folder of the group being loaded
            if ~exist('groupDirs','var')
                groupDirs{1} = pwd;
            elseif ~iscell(groupDirs)
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
            
            obj.FindAndLoadGroups(groupDirs, fmt, procStreamCfgFile);
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
        function status = FoundDataFilesInOtherFormat(obj, dataInit)            
            global supportedFormats
            status = false;
            k = [];

            format0 = dataInit.type;
            
            % Find index of another file format to try
            for ii = 1:length(supportedFormats)
                if ~isempty(findstr(dataInit.type, supportedFormats{ii,1}))
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
                dataInit = FindFiles(obj.dirnameGroup, supportedFormats{k});
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
                q = MenuBox([msg{:}], {'Rename (Recommended)','Delete','CANCEL'}, [], 90);
                if q==1
                    DeleteDataFiles(obj.dirnameGroup, format0, 'move')
                    status = true;
                elseif q==2
                    DeleteDataFiles(obj.dirnameGroup, format0)
                    status = true;
                end
            end            
        end

        
        
        % --------------------------------------------------------------
        function status = SelectOptionsWhenLoadFails(obj)
            status = -1;
    
            %             msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroup);
            %             msg{2} = sprintf('Do you want to select another group folder?');
            %             q = MenuBox([msg{:}], {'YES','NO'});
                        
            msg{1} = sprintf('Could not load any of the requested files in the group folder %s. ', obj.dirnameGroup);
            msg{2} = sprintf('Do you want to select another group folder?');
            q = MenuBox([msg{:}], {'YES','NO'}, [], 110);
            if q==2
                obj.logger.Write(sprintf('Skipping group folder %s...\n', obj.dirnameGroup));
                obj.dirnameGroup = 0;
                return;
            end
            obj.dirnameGroup = uigetdir(pwd, 'Please select another group folder ...');
            if obj.dirnameGroup==0
                obj.logger.Write(sprintf('Skipping group folder %s...\n', obj.dirnameGroup));
                return;
            end
            status = 0;
        end
        
        
        
        % --------------------------------------------------------------
        function FindAndLoadGroups(obj, groupDirs, fmt, procStreamCfgFile)
            
            for kk=1:length(groupDirs)
                
                obj.dirnameGroup = convertToStandardPath(groupDirs{kk});

                iGnew = length(obj.groups)+1;
                
                % Get file names and load them into DataTree
                while length(obj.groups) < iGnew
                    obj.files    = FileClass().empty();
                    obj.filesErr = FileClass().empty();
                    
                    dataInit = FindFiles(obj.dirnameGroup, fmt);
                    if isempty(dataInit) || dataInit.isempty()
                        return;
                    end
                    obj.files = dataInit.files;
                    
                    obj.LoadGroup(procStreamCfgFile);
                    if length(obj.groups) < iGnew
                        if obj.FoundDataFilesInOtherFormat(dataInit) 
                            continue;
                        elseif obj.SelectOptionsWhenLoadFails()<0
                            break;
                        end
                    end
                end
                
            end
            
        end
        
          
        % ---------------------------------------------------------------
        function LoadGroup(obj, procStreamCfgFile)
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load acquisition data from the data files
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AcqData2Group();
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Remove file entries from files array for data files 
            % which didn't load correctly because of format incompatibility
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.ErrorCheckLoadedFiles();

            tic;            
            for ii=1:length(obj.groups)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Load derived or post-acquisition data from a file if it
                % exists
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.groups(ii).Load();            
            
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Initialize procStream for all tree nodes
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.groups(ii).InitProcStream(procStreamCfgFile);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Generate the stimulus conditions for the group tree
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.groups(ii).SetConditions();                
            end
            obj.logger.Write(sprintf('Loaded processing stream results in %0.1f seconds\n', toc));
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find the amount of memory the whole group tree requires
            % at the run level. If group runs take up more than half a
            % GB then do not save dc and dod time courses and recalculate
            % dc and dod for each new current element (currElem) on the
            % fly. This should be a menu option in future releases
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % obj.logger.Write(sprintf('Memory required for data tree: %0.1f MB\n', obj.MemoryRequired() / 1e6));
        end
        
        
        % ----------------------------------------------------------
        function AcqData2Group(obj)
            if isempty(obj.files)
                return;
            end            
            groupCurr = GroupClass().empty();
            subjCurr = SubjClass().empty();
            runCurr = RunClass().empty();

            tic;            
            obj.logger.Write(sprintf('\n'));
            iG = 1;
            for iF=1:length(obj.files)
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
                if ~runCurr.IsEmpty()
                    obj.Add(groupCurr, subjCurr, runCurr);
                    runCurr = RunClass().empty();
                end
            end
            obj.logger.Write(sprintf('\nLoaded acquisition data in %0.1f seconds\n\n', toc));            
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
                obj.groups(jj).SetPath(obj.dirnameGroup)

                % In case there's not enough disk space in the current
                % group folder, we have a separate path for saving group
                % results
                obj.groups(jj).SetPathOutput(obj.dirnameGroup)
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


        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj, option)
            if ~exist('option','var')
                option = 'memory';
            end
            if isempty(obj)
                return;
            end
            
            nbytes = [0,0,0];
            kg = find(obj.groups.GroupsProcFlags==1);
            ks = find(obj.groups.SubjsProcFlags==1);
            kr = find(obj.groups.RunsProcFlags==1);
            
            % We assume for practcal purposes that unprocessed nodes take up zero bytes 
            if ~isempty(kg)
                nbytes(1) = length(kg) * obj.groups(kg(1)).MemoryRequired();
            end
            if ~isempty(ks)
                [iG,iS] = ind2sub(size(obj.groups.SubjsProcFlags), ks);
                nbytes(2) = length(ks) * obj.groups(iG(1)).subjs(iS(1)).MemoryRequired();
            end
            if ~isempty(kr)
                [iG,iS,iR] = ind2sub(size(obj.groups.RunsProcFlags), kr);
                nbytes(3) = length(kr) * obj.groups(iG(1)).subjs(iS(1)).runs(iR(1)).MemoryRequired(option);
            end
                        
            % Add up the bytes. 
            nbytes = sum(nbytes);
        end
        
        
        % ----------------------------------------------------------------------------------
        function diskspaceToSpare = CheckAvailableDiskSpace(obj, hwait)            
            if ishandle(hwait)
                obj.logger.Write(sprintf('Estimating disk space required to save processing results ...\n'), obj.logger.ProgressBar(), hwait);
            end
            
            % Calculate the amount of disk space already used by groupResults. Add that to free disk space because
            % groupResults will be overwritten 
            freeDiskSpace = 0;
            for ii = 1:length(obj.groups)
                freeDiskSpace = freeDiskSpace + GetFileSize([obj.groups(ii).pathOutput, 'groupResults.mat']);
            end
            
            memRequired = obj.MemoryRequired('disk');
            freeDiskSpace = getFreeDiskSpace() + freeDiskSpace;
            
            diskspaceToSpare = (freeDiskSpace - memRequired);   % Disk space to spare in megabytes
            diskspacePercentRemaining = 100 * diskspaceToSpare/memRequired;
            msg = {};
            obj.logger.Write(sprintf('CheckAvailableDiskSpace:    disk space available = %0.1f MB,    required disk space estimate = %0.1f MB\n', freeDiskSpace/1e6, memRequired/1e6));
            if diskspaceToSpare < 0
                msg{1} = sprintf('ERROR: Cannot save processing results requiring ~%0.1f MB of disk space on current drive with only %0.1f MB of free space available.\n', ...
                                  memRequired/1e6, freeDiskSpace/1e6);
                obj.warningflag = 0;
            elseif diskspacePercentRemaining < 200                
                msg{1} = sprintf('WARNING: Available disk space on the current drive is low (%0.1f MB). This may cause problems saving processing results in the future.', ...
                                  freeDiskSpace/1e6);
                msg{2} = sprintf('Consider moving your data set to a drive with more free space\n');
            end            
            if ~isempty(msg)
                if ~obj.warningflag
                    MessageBox([msg{:}]);
                    obj.warningflag = 1;
                end
                obj.logger.Write([msg{:}]);
            end            
        end
        
        
            
        % ----------------------------------------------------------
        function Save(obj, hwait)
            if ~exist('hwait','var')
                hwait = [];
            end
            
            % Check that there is anough disk space. NOTE: for now we
            % assume that all groups are on the same drive. This should be 
            % changed but for now we simplify. 
            if obj.CheckAvailableDiskSpace(hwait) < 0
                return;
            end
            
            t_local = tic;
            for ii = 1:length(obj.groups)
                obj.logger.Write(sprintf('Saving group %d in %s\n', ii, [obj.groups(ii).pathOutput, 'groupResults.mat']));                
                obj.groups(ii).Save(hwait);
            end
            obj.logger.Write(sprintf('Completed saving groupResults.mat for all groups in %0.3f seconds.\n', toc(t_local)));
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

    end
    
end