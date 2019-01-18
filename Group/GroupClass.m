classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        fileidx;
        nFiles;
        subjs;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = GroupClass(varargin)
            obj@TreeNodeClass(varargin);

            obj.type  = 'group';
            if nargin>0
                if ischar(varargin{1}) && strcmp(varargin{1},'copy')
                    return;
                end
                fname = varargin{1};
            else
                return;
            end
            
            if isempty(fname)
                subj = SubjClass().empty;
            else
                subj = SubjClass(fname, 1, 1, 1);
            end
            
            % Derive obj name from the name of the root directory
            curr_dir = pwd;
            k = sort([findstr(curr_dir,'/') findstr(curr_dir,'\')]);
            name = curr_dir(k(end)+1:end);
            
            obj.name = name;
            obj.type = 'group';
            obj.fileidx = 0;
            obj.nFiles = 0;
            obj.subjs = subj;
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
        function OverwriteProcInput(obj, varargin)
            
            % Overwrite procInput of group tree members of a single level
            % (ie., group, subject, run)
            
            procInput = ProcInputClass();
            
            if nargin==2
                if isproperty(varargin{1}, 'procElem')
                    type = varargin{1}.procElem.type;
                    procInput = varargin{1}.procElem.procInput;
                elseif isproperty(varargin{1}, 'procInput')
                    type = varargin{1}.type;
                    procInput = varargin{1}.procInput;
                end
            elseif nargin==3
                type = varargin{1};
                procInput = varargin{2};
            end
            
            % We don't want to be overwriting current procInput, with an
            % empty procInput.
            if procStreamIsEmpty(procInput)
                return;
            end
            
            switch(type)
                case 'group'
                    obj.procInput = procInput;
                case 'subj'
                    for ii=1:length(obj.subjs)
                        obj.subjs(ii).procInput = procInput;
                    end
                case 'run'
                    for ii=1:length(obj.subjs)
                        for jj=1:length(obj.subjs(ii).runs)
                            obj.subjs(ii).runs(jj).procInput = procInput;
                        end
                    end
            end
            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CopyProcInput(obj, varargin)
            
            % Copy procInput only to those group tree members at a single level
            % (ie., group, subject, run) with empty procInput
            procInput = ProcInputClass();
            if nargin==2
                if isproperty(varargin{1}, 'procElem')
                    type = varargin{1}.procElem.type;
                    procInput = varargin{1}.procElem.procInput;
                elseif isproperty(varargin{1}, 'procInput')
                    type = varargin{1}.type;
                    procInput = varargin{1}.procInput;
                end
            elseif nargin==3
                type = varargin{1};
                procInput = varargin{2};
            end
            
            % Copy default procInput to all uninitialized nodes in the group
            switch(type)
                case 'group'
                    if procStreamIsEmpty(obj.procInput)
                        obj.procInput = procStreamCopy2Native(procInput);
                    end
                case 'subj'
                    for jj=1:length(obj.subjs)
                        if procStreamIsEmpty(obj.subjs(jj).procInput)
                            obj.subjs(jj).procInput = procStreamCopy2Native(procInput);
                        end
                    end
                case 'run'
                    for jj=1:length(obj.subjs)
                        for kk=1:length(obj.subjs(jj).runs)
                            if procStreamIsEmpty(obj.subjs(jj).runs(kk).procInput)
                                obj.subjs(jj).runs(kk).procInput = procStreamCopy2Native(procInput);
                            end
                        end
                    end
            end
            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function [procInput, filename] = GetProcInputDefaultGroup(obj, filename)
            
            procInput = struct([]);
            if ~exist('filename','var') || isempty(filename)
                filename = '';
            end
            
            err1=0; err2=0;
            if procStreamIsEmpty(obj.procInput)
                err1=1; err2=1;
            else
                procInput = obj.procInput;
            end
            
            
            % Otherwise try loading procInput from a config file, but first
            % figure out the name of the config file
            while ~all(err1==0) || ~all(err2==0)
                
                % Load Processing stream file
                if isempty(filename)
                    [filename, pathname] = createDefaultConfigFile();
                    
                    % Load procInput from config file
                    fid = fopen(filename,'r');
                    [procInput, err1] = procStreamParse(fid, obj);
                    fclose(fid);
                elseif ~isempty(filename)
                    % Load procInput from config file
                    fid = fopen(filename,'r');
                    [procInput err1] = procStreamParse(fid, obj);
                    fclose(fid);
                else
                    err1=0;
                end
                
                % Check loaded procInput for syntax and semantic errors
                if procStreamIsEmpty(procInput) && err1==0
                    ch = menu('Warning: config file is empty.','Okay');
                elseif err1==1
                    ch = menu('Syntax error in config file.','Okay');
                end
                
                [err2, iReg] = procStreamErrCheck(procInput);
                if ~all(~err2)
                    i=find(err2==1);
                    str1 = 'Error in functions\n\n';
                    for j=1:length(i)
                        str2 = sprintf('%s%s',procInput.procFunc(i(j)).funcName,'\n');
                        str1 = strcat(str1,str2);
                    end
                    str1 = strcat(str1,'\n');
                    str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
                    ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
                    if ch==1
                        [procInput, err2] = procStreamFixErr(err2, procInput, iReg);
                    elseif ch==2
                        filename = './processOpt_default.cfg';
                        procStreamFileGen(filename);
                        fid = fopen(filename,'r');
                        procInput = procStreamParse(fid, run);
                        fclose(fid);
                        break;
                    elseif ch==3
                        filename = '';
                        return;
                    end
                end
            end  % function [procInput, filename] = GetProcInputDefaultGroup(obj, filename)
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Calc(obj, hListbox, listboxFuncPtr)
            % Calculate all subjs in this session
            subjs = obj.subjs;
            nSubj = length(subjs);
            for iSubj = 1:nSubj
                subjs(iSubj).Calc(hListbox, listboxFuncPtr);
                
                % Find smallest tHRF among the subjs. We should make this the common one.
                if iSubj==1
                    tHRF_common = subjs(iSubj).procResult.tHRF;
                elseif length(subjs(iSubj).procResult.tHRF) < length(tHRF_common)
                    tHRF_common = subjs(iSubj).procResult.tHRF;
                end
            end
                        
            % Change and display position of current processing
            listboxFuncPtr(hListbox, [0,0]);
            
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all subjs. Use smallest tHRF as the common one.
            for iSubj = 1:nSubj
                subjs(iSubj).procResult.SettHRFCommon(tHRF_common, subjs(iSubj).name, subjs(iSubj).type);
            end
            
            
            % Instantiate all the variables that might be needed by
            % procStreamCalc to calculate proc stream for this group
            for iSubj = 1:nSubj
                dodAvgSubjs{iSubj}    = subjs(iSubj).procResult.dodAvg;
                dodAvgStdSubjs{iSubj} = subjs(iSubj).procResult.dodAvgStd;
                dcAvgSubjs{iSubj}     = subjs(iSubj).procResult.dcAvg;
                dcAvgStdSubjs{iSubj}  = subjs(iSubj).procResult.dcAvgStd;
                tHRFSubjs{iSubj}      = subjs(iSubj).procResult.tHRF;
                nTrialsSubjs{iSubj}   = subjs(iSubj).procResult.nTrials;
                if ~isempty(subjs(iSubj).procResult.ch)
                    SDSubjs{iSubj}    = subjs(iSubj).procResult.ch;
                else
                    SDSubjs{iSubj}    = subjs(iSubj).ch;
                end
            end
            procStreamCalc();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procResult
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procResult = ProcResultClass();
            for jj=1:length(obj.subjs)
                obj.subjs(jj).Reset();
            end
        end
        
        
    end   % Public methods
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Save/Load methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function Load(obj)
            if exist('./groupResults.mat','file')
                load( './groupResults.mat' );
                
                % copy procResult from previous group to current group for
                % all nodes that still exist in the current group.
                hwait = waitbar(0,'Loading group');
                obj.copyProcParams(group);
                close(hwait);
            else
                group = obj;
                save( './groupResults.mat','group' );
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('optionsstr','var')
                options = 'acquired:derived';
            end
            options_s = obj.parseSaveOptions(options);
            
            % Save derived data
            if options_s.derived
                group = obj;
                save( './groupResults.mat','group' );
            end
            
            % Save acquired data
            if options_s.acquired
                for ii=1:length(obj.subjs)
                    obj.subjs(ii).Save('acquired');
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
        function SetMeasList(obj)
            for ii=1:length(obj.subjs)
                obj.subjs(ii).SetMeasList();
            end
        end

        
        % ----------------------------------------------------------------------------------
        function ch = GetMeasList(obj)
            ch = obj.subjs(1).GetMeasList();
        end

        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.subjs(1).GetWls();
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
            for ii=1:length(obj.subjs)
                obj.subjs(ii).RenameCondition(oldname, newname);
            end
        end

        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj)
            CondNames = {};
            for ii=1:length(obj.subjs)
                obj.subjs(ii).SetConditions();
                CondNames = [CondNames, obj.subjs(ii).GetConditions()];
            end
            obj.CondNames    = unique(CondNames);
            obj.CondNamesAll(obj.CondNames);
	
            % Generate mapping of group conditions to subject conditions
            % used when averaging subject HRF to get group HRF
            obj.SetCondName2Subj();            
            for iSubj=1:length(obj.subjs)
                obj.subjs(iSubj).SetCondName2Run();
                obj.subjs(iSubj).SetCondName2Group(obj.CondNames);
            end
            
            % For group this is an identity table
            obj.CondName2Group = 1:length(obj.CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        % Generates mapping of group conditions to subject conditions
        % used when averaging subject HRF to get group HRF
        % ----------------------------------------------------------------------------------
        function SetCondName2Subj(obj)
            obj.procInput.CondName2Subj = zeros(length(obj.subjs),length(obj.CondNames));
            for iC=1:length(obj.CondNames)
                for iSubj=1:length(obj.subjs)
                    k = find(strcmp(obj.CondNames{iC}, obj.subjs(iSubj).GetConditions()));
                    if isempty(k)
                        obj.procInput.CondName2Subj(iSubj,iC) = 0;
                    else
                        obj.procInput.CondName2Subj(iSubj,iC) = k(1);
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNameIdx = GetCondNameIdx(obj, CondNameIdx)
            ;
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
        
    end      % Public Set/Get methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods  (Access = {})
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % N2 to obj if obj and N2 are equivalent nodes
        % ----------------------------------------------------------------------------------
        function copyProcParams(obj, G)
            if strcmp(obj.name,G.name)
                for i=1:length(obj.subjs)
                    j = obj.existSubj(i,G);
                    if (j>0)
                        obj.subjs(i).copyProcParams(G.subjs(j));
                    end
                end
                if obj == G
                    obj.copyProcParamsFieldByField(G);
                else
                    obj.procInput.changeFlag=1;
                end
            end           
        end
        
        
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

