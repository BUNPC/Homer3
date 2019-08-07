classdef DataTreeClass <  handle
    
    properties
        files
        filesErr
        group
        currElem
        reg
        config
    end
    
    methods
        
        % ---------------------------------------------------------------
        function obj = DataTreeClass(fmt, procStreamCfgFile)
            obj.group         = GroupClass().empty();
            obj.currElem      = TreeNodeClass().empty();
            obj.reg           = RegistriesClass().empty();
            obj.config        = ConfigFileClass().empty();
            
            if ~exist('fmt','var')
                fmt = '';
            end
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
                       
            dirnameGroup = '';
                       
            % Get file names and load them into DataTree
            while obj.IsEmpty()
                obj.files    = FileClass().empty();
                obj.filesErr = FileClass().empty();
                
                dataInit = FindFiles(fmt, dirnameGroup);
                if isempty(dataInit) || dataInit.isempty()
                    return;
                end
                obj.files = dataInit.files;

                obj.LoadData(procStreamCfgFile);
                if obj.IsEmpty()                    
                    msg{1} = sprintf('Could not load any of the requested files in the current group folder. ');
                    msg{2} = sprintf('Do you want to select another group folder?');
                    q = MenuBox([msg{:}], {'YES','NO'});
                    if q==2
                        return;
                    end
                    dirnameGroup = uigetdir(pwd, 'Please select another group folder ...');
                    if dirnameGroup==0
                        return;
                    end
                end
            end
            
            % Load user function registry
            obj.reg = RegistriesClass();
            if ~isempty(obj.reg.GetSavedRegistryPath())
                fprintf('Loaded saved registry %s\n', obj.reg.GetSavedRegistryPath());
            end            
            
            % Initialize the current processing element within the group
            obj.SetCurrElem(1,1,1);
        end
        
        
        % --------------------------------------------------------------
        function delete(obj)
            if isempty(obj.currElem)
                return;
            end
        end


        % ---------------------------------------------------------------
        function LoadData(obj, procStreamCfgFile)
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

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load derived or post-acquisition data from a file if it 
            % exists
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.Load();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize procStream for all tree nodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.InitProcStream(procStreamCfgFile);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Generate the stimulus conditions for the group tree
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.SetConditions();
        end
        
        
        % ----------------------------------------------------------
        function AcqData2Group(obj)
            if isempty(obj.files)
                return;
            end            
            groupCurr = GroupClass().empty();
            subjCurr = SubjClass().empty();
            runCurr = RunClass().empty();
            
            fprintf('\n');
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
            fprintf('\n');            
        end


       
        % ----------------------------------------------------------
        function Add(obj, group, subj, run)
            if nargin<2
                return;
            end
                        
            % Add group to this dataTree
            jj=0;
            for ii=1:length(obj.group)
                if strcmp(obj.group(ii).GetName, group.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.group)+1;
                group.SetIndexID(jj);
                obj.group(jj) = group;
                fprintf('Added group %s to dataTree.\n', obj.group(jj).GetName);
            end

            %v Add subj and run to group
            obj.group.Add(subj, run);            
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
            for ii=1:length(obj.group)
                list = [list; obj.group(ii).DepthFirstTraversalList()];
            end
        end        
        
        
        % ----------------------------------------------------------
        function SetCurrElem(obj, iGroup, iSubj, iRun)
            if obj.group.IsEmpty()
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
                obj.currElem = obj.group(iGroup);
            elseif iSubj>0 && iRun==0
                obj.currElem = obj.group(iGroup).subjs(iSubj);
            elseif iSubj>0 && iRun>0
                obj.currElem = obj.group(iGroup).subjs(iSubj).runs(iRun);
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
        function SaveCurrElem(obj)
            obj.currElem.Save();
        end


        % ----------------------------------------------------------
        function CalcCurrElem(obj)
            obj.currElem.Calc();
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
            if obj.group.IsEmpty()
                return;
            end
            b = false;
        end

    end
    
end