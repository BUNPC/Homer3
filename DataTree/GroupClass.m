classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        version;
        versionStr;
        subjs;
        spacesaver;
    end
    
    properties % (Access = private)
        path
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
                fprintf('Current GroupClass version %s\n', obj.GetVersionStr());
            end
            
            obj.type    = 'group';
            obj.subjs   = SubjClass().empty;
            obj.spacesaver = false;
            
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
                k = sort([findstr(curr_dir,'/') findstr(curr_dir,'\')]);
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
            if nargin==1
                obj.version{1} = '1';   % Major version #
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
        function InitVersionStrFull(obj)
            if isempty(obj.version)
                return;
            end
            verstr = version2string(obj.version);
            obj.versionStr = sprintf('%s: GroupClass v%s',  MainGUIVersion('exclpath'), verstr);
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
                if ~isnumber([obj2.version{:}])
                    res = 1;
                end
                v2 = obj2.version;
            end
            v1 = obj.version;
            
            for ii=1:length(v1)
                v1{ii} = str2num(v1{ii});
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
        % Copy processing params (procInut and procStream.output) from
        % N2 to obj if obj and N2 are equivalent nodes
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, conditional)
            if nargin==3 && strcmp(conditional, 'conditional')
                if strcmp(obj.name,obj2.name)
                    for i=1:length(obj.subjs)
                        j = obj.existSubj(i,obj2);
                        if (j>0)
                            obj.subjs(i).Copy(obj2.subjs(j), 'conditional');
                        end
                    end
                    if obj == obj2
                        obj.Copy@TreeNodeClass(obj2, 'conditional');
                    end
                end
            else
                if obj.spacesaver
                    option = 'spacesaver';
                else
                    option = 'saveall';
                end
                for i=1:length(obj2.subjs)
                    obj.subjs(i) = SubjClass(obj2.subjs(i), option);
                end
                obj.Copy@TreeNodeClass(obj2);
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
                    for jj=1:length(obj.subjs)
                        obj.subjs(jj).procStream.CopyFcalls(procStream);
                    end
                case 'run'
                    for jj=1:length(obj.subjs)
                        for kk=1:length(obj.subjs(jj).runs)
                            obj.subjs(jj).runs(kk).procStream.CopyFcalls(procStream);
                        end
                    end
            end
        end

        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return;
            end
            for ii=1:length(obj.subjs)
                nbytes = nbytes + obj.subjs(ii).MemoryRequired();
            end
            if nbytes > 5e8
                obj.spacesaver = true;
            end
        end


        % ----------------------------------------------------------------------------------
        function SetPath(obj, dirname)
            obj.path = dirname;
        end
        
        
        % ----------------------------------------------------------------------------------
        function Add(obj, subj, run)                        
            % Add subject to this group
            jj=0;
            for ii=1:length(obj.subjs)
                if strcmp(obj.subjs(ii).GetName(), subj.GetName())
                    jj=ii;
                    break;
                end
            end
            if jj==0
                jj = length(obj.subjs)+1;
                subj.SetIndexID(obj.iGroup, jj);
                obj.subjs(jj) = subj;
                fprintf('   Added subject %s to group %s.\n', obj.subjs(jj).GetName, obj.GetName);
            end
            
            % Add run to subj
            obj.subjs(jj).Add(run);
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
            % input at each level from the save results groupresults.mat 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            g = obj;
            s = obj.subjs(1);
            r = obj.subjs(1).runs(1);
            for jj=1:length(obj.subjs)
                if ~obj.subjs(jj).procStream.IsEmpty()
                    s = obj.subjs(jj);
                end
                for kk=1:length(obj.subjs(jj).runs)
                    if ~obj.subjs(jj).runs(kk).procStream.IsEmpty()
                        r = obj.subjs(jj).runs(kk);
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
                
                fprintf('Attempting to load proc stream from %s\n', fname);
                
                % Load file to the first empty procStream in the dataTree at each processing level
                g.LoadProcStreamConfigFile(fname);
                s.LoadProcStreamConfigFile(fname);
                r.LoadProcStreamConfigFile(fname);
                
                % Copy the loaded procStream at each processing level to all
                % nodes of that level that lack procStream 
                
                % If proc stream input is still empty it means the loaded config
                % did not have valid proc stream input. If that's the case we
                % load a default proc stream input
                if g.procStream.IsEmpty() || s.procStream.IsEmpty() || r.procStream.IsEmpty()
                    fprintf('Failed to load all function calls in proc stream config file. Loading default proc stream...\n');
                    g.CopyFcalls(procStreamGroup, 'group');
                    g.CopyFcalls(procStreamSubj, 'subj');
                    g.CopyFcalls(procStreamRun, 'run');
                    
                    % If user asked default config file to be generated ...
                    if autoGenDefaultFile
                        fprintf('Generating default proc stream config file %s\n', fname);
                        
                        % Move exiting default config to same name with .bak extension
                        if ~exist([fname, '.bak'], 'file')
                            fprintf('Moving existing %s to %s.bak\n', fname, fname);
                            movefile(fname, [fname, '.bak']);
                        end
                        procStreamGroup.SaveConfigFile(fname, 'group');
                        procStreamSubj.SaveConfigFile(fname, 'subj');
                        procStreamRun.SaveConfigFile(fname, 'run');
                    end
                else
                    fprintf('Loading proc stream from %s\n', fname);
                    procStreamGroup.Copy(g.procStream);
                    procStreamSubj.Copy(s.procStream);
                    procStreamRun.Copy(r.procStream);
                    g.CopyFcalls(procStreamGroup, 'group');
                    g.CopyFcalls(procStreamSubj, 'subj');
                    g.CopyFcalls(procStreamRun, 'run');
                end
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
                fprintf('Calculating processing stream for group %d\n', obj.iGroup)
            end
            
            % Calculate all subjs in this session
            s = obj.subjs;
            nSubj = length(s);
            nDataBlks = s(1).GetDataBlocksNum();
            tHRF_common = cell(nDataBlks,1);
            for iSubj = 1:nSubj
                s(iSubj).Calc();
                
                % Find smallest tHRF among the subjs. We should make this the common one.
                for iBlk = 1:nDataBlks
	                if isempty(tHRF_common{iBlk})
                        tHRF_common{iBlk} = s(iSubj).procStream.output.GetTHRF(iBlk);
                    elseif length(s(iSubj).procStream.output.GetTHRF(iBlk)) < length(tHRF_common{iBlk})
                        tHRF_common{iBlk} = s(iSubj).procStream.output.GetTHRF(iBlk);
                    end
                end
                
            end
           
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all subjs. Use smallest tHRF as the common one.
            for iSubj = 1:nSubj
                for iBlk = 1:length(tHRF_common)
                    s(iSubj).procStream.output.SettHRFCommon(tHRF_common{iBlk}, s(iSubj).name, s(iSubj).type, iBlk);
                end
            end
            
            % Instantiate all the variables that might be needed by
            % procStream.Calc() to calculate proc stream for this group
            vars = [];
            for iSubj = 1:nSubj
                vars.dodAvgSubjs{iSubj}    = s(iSubj).procStream.output.GetVar('dodAvg');
                vars.dodAvgStdSubjs{iSubj} = s(iSubj).procStream.output.GetVar('dodAvgStd');
                vars.dcAvgSubjs{iSubj}     = s(iSubj).procStream.output.GetVar('dcAvg');
                vars.dcAvgStdSubjs{iSubj}  = s(iSubj).procStream.output.GetVar('dcAvgStd');
                vars.tHRFSubjs{iSubj}      = s(iSubj).procStream.output.GetTHRF();
                vars.nTrialsSubjs{iSubj}   = s(iSubj).procStream.output.GetVar('nTrials');
                vars.SDSubjs{iSubj}        = s(iSubj).GetMeasList();
            end
            
            % Make variables in this group available to processing stream input
            obj.procStream.input.LoadVars(vars);

            % Calculate processing stream
            obj.procStream.Calc();

            if obj.DEBUG
                fprintf('Completed processing stream for group %d\n', obj.iGroup);
                fprintf('\n');
            end
            
            % Update call application GUI using it's generic Update function
            if ~isempty(obj.updateParentGui)
                obj.updateParentGui('DataTreeClass', [obj.iGroup, obj.iSubj, obj.iRun]);
            end
            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CalcRunLevelTimeCourse(obj)
            % Calculate all subjs in this session
            s = obj.subjs;
            nSubj = length(s);
            for iSubj = 1:nSubj
                s(iSubj).CalcRunLevelTimeCourse();
            end
        end
        

        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 0;
            end
            fprintf('%sGroup 1:\n', blanks(indent));
            obj.procStream.Print(indent+4);
            obj.procStream.output.Print(indent+4);
            for ii=1:length(obj.subjs)
                obj.subjs(ii).Print(indent+4);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procStream.output
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procStream.output = ProcResultClass();
            for jj=1:length(obj.subjs)
                obj.subjs(jj).Reset();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            for ii=1:length(obj.subjs)
                if ~obj.subjs(ii).IsEmpty()
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
        function Load(obj)
            if isempty(obj)
                return;
            end
            group = [];
            if exist([obj.path, 'groupResults.mat'],'file')
                g = load([obj.path, 'groupResults.mat']);
                
                % Do some basic error checks on groupResults contents
                if isproperty(g, 'group') && isa(g.group, 'GroupClass')
                    if isproperty(g.group, 'version')
                        if ismethod(g.group, 'GetVersion')
                            fprintf('Saved group data, version %s exists\n', g.group.GetVersionStr());
                            group = g.group;
                        end
                    end
                end
            end
            
            % Copy saved group to current group if versions are compatible.
            % obj.CompareVersions==0 means the versions of the saved group
            % and current one are equal.
            if ~isempty(group) && obj.CompareVersions(group)<=0
                % copy procStream.output from previous group to current group for
                % all nodes that still exist in the current group .
                hwait = waitbar(0,'Loading group');
                obj.Copy(group, 'conditional');
                close(hwait);
            else
                group = obj;
                if exist([obj.path, 'groupResults.mat'],'file')
                    fprintf('Warning: This folder contains old version of groupResults.mat. Will move it to groupResults_old.mat\n');
                    movefile([obj.path, 'groupResults.mat'], './groupResults_old.mat')
                end
                save([obj.path, 'groupResults.mat'],'group' );
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj)
            fprintf('Saving processed data in %s\n', [obj.path, 'groupResults.mat']);
            t_local = tic;
            group = GroupClass(obj);
            try 
                save([obj.path, 'groupResults.mat'],'group' );
            catch
                msg{1} = sprintf('WARNING: Could not save computation output to groupResults.mat file in the subject folder\n\n');
                msg{2} = sprintf('%s\n\n', pwd);
                msg{3} = sprintf('This could be because the file or the subject folder itself is read-only.');
                msg{4} = sprintf('To fix this change groupResults.mat file write permissions to read/write.');
                MessageBox([msg{:}]);
            end            
            fprintf('Completed saving groupResults.mat in %0.3f seconds.\n', toc(t_local));
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ExportHRF(obj, options, iBlk)
            if nargin<2 || isempty(options)
                q = MenuBox('Export only current group data OR current group data and all it''s subject data?', ...
                            {'Current group data only','Current group data and all it''s subject data','Cancel'});
                if q==1
                    options  = 'current';
                elseif q==2
                    options  = 'all';
                else
                    return
                end
            end
            if nargin<3
                iBlk = 1;
            end
            
            obj.procStream.ExportHRF(obj.name, obj.CondNames, iBlk);
            if strcmp(options, 'all')
                for ii=1:length(obj.subjs)
                    obj.subjs(ii).ExportHRF('all', iBlk);
                end
            end
        end
                
        
    end  % Public Save/Load methods
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj)
            SD = obj.subjs(1).GetSDG();
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
        function aux = GetAuxiliary(obj)
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
                
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
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
                
    end  % Private methods

end % classdef GroupClass < TreeNodeClass

