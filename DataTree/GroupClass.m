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
        function CopyProcInput(obj, type, procInput, mode)
            if ~exist('mode','var')
                mode = 'nooverwrite';
            end
            
            % Copy default procInput to all uninitialized nodes in the group
            switch(type)
                case 'group'
                    if obj.procStream.IsEmpty() || strcmp(mode, 'overwrite')
                        obj.procStream.input = procInput.copy();
                    end
                case 'subj'
                    for jj=1:length(obj.subjs)
                        if obj.subjs(jj).procStream.IsEmpty() || strcmp(mode, 'overwrite')
                            obj.subjs(jj).procStream.input = procInput.copy();
                        end
                    end
                case 'run'
                    for jj=1:length(obj.subjs)
                        for kk=1:length(obj.subjs(jj).runs)
                            if obj.subjs(jj).runs(kk).procStream.IsEmpty() || strcmp(mode, 'overwrite')
                                obj.subjs(jj).runs(kk).procStream.input = procInput.copy();
                            end
                        end
                    end
            end            
        end
        

        % ----------------------------------------------------------------------------------
        function CopyProcInputFunc(obj, type, procInput)
            % Copy default procInput to all uninitialized nodes in the group
            switch(type)
                case 'group'
                    obj.procStream.input.func = procInput.func;
                case 'subj'
                    for jj=1:length(obj.subjs)
                        obj.subjs(jj).procStream.input.func = procInput.func;
                    end
                case 'run'
                    for jj=1:length(obj.subjs)
                        for kk=1:length(obj.subjs(jj).runs)
                            obj.subjs(jj).runs(kk).procStream.input.func = procInput.func;
                        end
                    end
            end            
        end
        
               
        % ----------------------------------------------------------------------------------
        function Calc(obj, hListbox, listboxFuncPtr)
            if ~exist('hListbox','var')
                hListbox = [];
            end
            if ~exist('listboxFuncPtr','var')
                listboxFuncPtr = [];
            end
            
            % Calculate all subjs in this session
            subjs = obj.subjs;
            nSubj = length(subjs);
            for iSubj = 1:nSubj
                subjs(iSubj).Calc(hListbox, listboxFuncPtr);
                
                % Find smallest tHRF among the subjs. We should make this the common one.
                if iSubj==1
                    tHRF_common = subjs(iSubj).procStream.output.GetVar('tHRF');
                elseif length(subjs(iSubj).procStream.output.tHRF) < length(tHRF_common)
                    tHRF_common = subjs(iSubj).procStream.output.GetVar('tHRF');
                end
            end
                        
            % Change and display position of current processing
            if ~isempty(listboxFuncPtr)
                listboxFuncPtr(hListbox, [0,0]);
            end
            
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all subjs. Use smallest tHRF as the common one.
            for iSubj = 1:nSubj
                subjs(iSubj).procStream.output.SettHRFCommon(tHRF_common, subjs(iSubj).name, subjs(iSubj).type);
            end
            
            % Instantiate all the variables that might be needed by
            % procStream.Calc() to calculate proc stream for this group
            vars = [];
            for iSubj = 1:nSubj
                vars.dodAvgSubjs{iSubj}    = subjs(iSubj).procStream.output.GetVar('dodAvg');
                vars.dodAvgStdSubjs{iSubj} = subjs(iSubj).procStream.output.GetVar('dodAvgStd');
                vars.dcAvgSubjs{iSubj}     = subjs(iSubj).procStream.output.GetVar('dcAvg');
                vars.dcAvgStdSubjs{iSubj}  = subjs(iSubj).procStream.output.GetVar('dcAvgStd');
                vars.tHRFSubjs{iSubj}      = subjs(iSubj).procStream.output.GetVar('tHRF');
                vars.nTrialsSubjs{iSubj}   = subjs(iSubj).procStream.output.GetVar('nTrials');
                if ~isempty(subjs(iSubj).procStream.output.GetVar('ch'))
                    vars.SDSubjs{iSubj}    = subjs(iSubj).procStream.output.GetVar('ch');
                else
                    vars.SDSubjs{iSubj}    = subjs(iSubj).GetVar('ch');
                end
            end
            
            % Make variables in this group available to processing stream input
            obj.procStream.input.LoadVars(vars);

            % Calculate processing stream
            obj.procStream.Calc();
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
        
        
    end   % Public methods
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Save/Load methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function Load(obj)
            if exist('./groupResults.mat','file')
                load( './groupResults.mat' );
                
                % copy procStream.output from previous group to current group for
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
            obj.procStream.input.CondName2Subj = zeros(length(obj.subjs),length(obj.CondNames));
            for iC=1:length(obj.CondNames)
                for iSubj=1:length(obj.subjs)
                    k = find(strcmp(obj.CondNames{iC}, obj.subjs(iSubj).GetConditions()));
                    if isempty(k)
                        obj.procStream.input.CondName2Subj(iSubj,iC) = 0;
                    else
                        obj.procStream.input.CondName2Subj(iSubj,iC) = k(1);
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
        % Copy processing params (procInut and procStream.output) from
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
                    obj.procStream.input.changeFlag=1;
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

