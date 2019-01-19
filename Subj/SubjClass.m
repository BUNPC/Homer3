classdef SubjClass < TreeNodeClass
    
    properties % (Access = private)
        iSubj;
        runs;
    end
    
    methods
        
        
        % ----------------------------------------------------------------------------------
        function obj = SubjClass(varargin)
            obj@TreeNodeClass(varargin);
            
            obj.type  = 'subj';
            if nargin==4
                fname = varargin{1};
                iSubj = varargin{2};
                iRun  = varargin{3};
                rnum  = varargin{4};
            else
                return;
            end
            
            sname = getSubjNameAndRun(fname, rnum);
            if isempty(fname) || exist(fname,'file')~=2
                run = RunClass().empty;
            else
                run = RunClass(fname, iSubj, iRun, rnum);
            end
            
            obj.name = sname;
            obj.type = 'subj';
            obj.iSubj = iSubj;
            obj.procInput.CondName2Run = [];
            obj.CondName2Group = [];
            obj.runs = run;
        end
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % S to obj if obj and S are equivalent nodes
        % ----------------------------------------------------------------------------------
        function copyProcParams(obj, S)
            if strcmp(obj.name, S.name)
                for i=1:length(obj.runs)
                    j = obj.existRun(i,S);
                    if (j>0)
                        obj.runs(i).copyProcParams(S.runs(j));
                    end
                end
                if obj == S
                    obj.copyProcParamsFieldByField(S);
                else
                    obj.procInput.changeFlag = 1;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Check whether run R exists in this subject and return
        % its index if it does exist. Else return 0.
        % ----------------------------------------------------------------------------------
        function j = existRun(obj, k, S)
            j=0;
            for i=1:length(S.runs)
                [~,rname1] = fileparts(obj.runs(k).name);
                [~,rname2] = fileparts(S.runs(i).name);
                if strcmp(rname1,rname2)
                    j=i;
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of runs are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            if ~strcmp(obj1.name, obj2.name)
                B=0;
                return;
            end
            for i=1:length(obj1.runs)
                j = existRun(obj1, i, obj2);
                if j==0
                    B=0;
                    return;
                end
            end
            for i=1:length(obj2.runs)
                j = existRun(obj2, i, obj1);
                if j==0
                    B=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('options','var')
                options = 'acquired:derived';
            end
            options_s = obj.parseSaveOptions(options);
            
            % Save derived data
            if options_s.derived
                if exist('./groupResults.mat','file')
                    load( './groupResults.mat' );
                    if strcmp(class(group.subjs(obj.iSubj)), class(obj))
                        group.subjs(obj.iSubj) = obj;
                    end
                    save( './groupResults.mat','group' );
                end
            end
            
            % Save acquired data
            if options_s.acquired
                strPrintable = sprintf_s(obj.name);
                h = waitbar(0, sprintf('Saving subject %s', strPrintable));
                pause(1);
                n = length(obj.runs);
                for ii=1:n
                    obj.runs(ii).Save('acquired');
                    waitbar(ii/n, h, sprintf('Saving run %d of %d of subject %s', ii, n, strPrintable))
                end
                close(h);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procResult
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procResult = ProcResultClass();
            for jj=1:length(obj.runs)
                obj.runs(jj).Reset();
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
            
            % Calculate all runs in this session
            runs = obj.runs;
            nRun = length(runs);
            for iRun = 1:nRun
                runs(iRun).Calc(hListbox, listboxFuncPtr);
                
                % Find smallest tHRF among the runs. We should make this the common one.
                if iRun==1
                    tHRF_common = runs(iRun).procResult.tHRF;
                elseif length(runs(iRun).procResult.tHRF) < length(tHRF_common)
                    tHRF_common = runs(iRun).procResult.tHRF;
                end
            end
            
            % Change and display position of current processing
            if ~isempty(listboxFuncPtr)
                listboxFuncPtr(hListbox, [obj.iSubj, 0]);
            end
            
            % Set common tHRF: make sure size of tHRF, dcAvg and dcAvg is same for
            % all runs. Use smallest tHRF as the common one.
            for iRun = 1:nRun
                runs(iRun).procResult.SettHRFCommon(tHRF_common, runs(iRun).name, runs(iRun).type);
            end            
            
            % Instantiate all the variables that might be needed by
            % procStreamCalc to calculate proc stream for this subject
            nTrials = zeros(1,length(obj.CondNames));
            for iRun = 1:nRun
                obj.procInput.misc.dodAvgRuns{iRun}    = runs(iRun).procResult.dodAvg;
                obj.procInput.misc.dodAvgStdRuns{iRun} = runs(iRun).procResult.dodAvgStd;
                obj.procInput.misc.dodSum2Runs{iRun}   = runs(iRun).procResult.dodSum2;
                obj.procInput.misc.dcAvgRuns{iRun}     = runs(iRun).procResult.dcAvg;
                obj.procInput.misc.dcAvgStdRuns{iRun}  = runs(iRun).procResult.dcAvgStd;
                obj.procInput.misc.dcSum2Runs{iRun}    = runs(iRun).procResult.dcSum2;
                obj.procInput.misc.tHRFRuns{iRun}      = runs(iRun).procResult.tHRF;
                obj.procInput.misc.nTrialsRuns{iRun}   = runs(iRun).procResult.nTrials;
                if ~isempty(runs(iRun).procResult.ch)
                    obj.procInput.misc.SDRuns{iRun}    = runs(iRun).procResult.ch;
                else
                    obj.procInput.misc.SDRuns{iRun}    = runs(iRun).GetMeasList();
                end
            end

            % Calculate processing stream
            procStreamCalc(obj);
        end
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function SetSDG(obj)
            obj.SD = obj.runs(1).GetSDG();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj)
            SD = obj.runs(1).GetSDG();
        end
        
        
        % ----------------------------------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            srcpos = obj.runs(1).GetSrcPos();
        end
        
        
        % ----------------------------------------------------------------------------------
        function detpos = GetDetPos(obj)
            detpos = obj.runs(1).GetDetPos();
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.runs(1).GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetMeasList(obj)
            for ii=1:length(obj.runs)
                obj.runs(ii).SetMeasList();
            end
        end

        
        % ----------------------------------------------------------------------------------
        function ch = GetMeasList(obj)
            ch = obj.runs(1).GetMeasList();
        end
                
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.runs(1).GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj)
            CondNames = {};
            for ii=1:length(obj.runs)
                obj.runs(ii).SetConditions();
                CondNames = [CondNames, obj.runs(ii).GetConditions()];
            end
            obj.CondNames = unique(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetCondName2Group(obj, CondNamesGroup)
            obj.CondName2Group = zeros(1, length(obj.CondNames));
            for ii=1:length(obj.CondNames)
                obj.CondName2Group(ii) = find(strcmp(CondNamesGroup, obj.CondNames{ii}));
            end
            for iRun=1:length(obj.runs)
                obj.runs(iRun).SetCondName2Group(CondNamesGroup);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetCondName2Run(obj)
            % Generate the second output parameter - CondSubj2Run using the 1st
            obj.procInput.CondName2Run = zeros(length(obj.runs), length(obj.CondNames));
            for iC=1:length(obj.CondNames)
                for iRun=1:length(obj.runs)
                    k = find(strcmp(obj.CondNames{iC}, obj.runs(iRun).GetConditions()));
                    if isempty(k)
                        obj.procInput.CondName2Run(iRun,iC) = 0;
                    else
                        obj.procInput.CondName2Run(iRun,iC) = k(1);
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNameIdx = GetCondNameIdx(obj, CondNameIdx)
            CondNameIdx = find(obj.CondName2Group == CondNameIdx);
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            for ii=1:length(obj.runs)
                CondNamesRun = obj.runs(ii).GetConditionsActive();
                for jj=1:length(CondNames)
                    k = find(strcmp(['-- ', CondNames{jj}], CondNamesRun));
                    if ~isempty(k)
                        CondNames{jj} = ['-- ', CondNames{jj}];
                    end
                end
            end
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
            for ii=1:length(obj.runs)
                obj.runs(ii).RenameCondition(oldname, newname);
            end
        end
        
    end
        
end
