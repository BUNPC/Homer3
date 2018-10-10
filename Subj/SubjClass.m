classdef SubjClass < TreeNodeClass
    
    properties % (Access = private)
        
        iRun;
        CondName2Run
        CondName2Group;
        runs;
        
    end
    
    methods
        
        
        % ----------------------------------------------------------------------------------
        function obj = SubjClass(varargin)
            
            if nargin==4
                fname = varargin{1};
                iRun = varargin{2};
                iRun  = varargin{3};
                rnum  = varargin{4};
            else
                return;
            end
            
            sname = getSubjNameAndRun(fname, rnum);
            if isempty(fname) || exist(fname,'file')~=2
                run = RunClass().empty;
            else
                run = RunClass(fname, iRun, iRun, rnum);
            end
            
            obj.name = sname;
            obj.type = 'subj';
            obj.iRun = iRun;
            obj.CondName2Run = [];
            obj.CondName2Group = [];
            obj.iRun = iRun;
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
        % Copy processing params (procInut and procResult) from
        % S to obj
        % ----------------------------------------------------------------------------------
        function copyProcParamsFieldByField(obj, S)
            
            % procInput
            if isproperty(S,'procInput')
                if isproperty(S.procInput,'procFunc') && ~isempty(S.procInput.procFunc)
                    obj.procInput = copyStructFieldByField(obj.procInput, S.procInput);
                else
                    [obj.procInput.procFunc, obj.procInput.procParam] = procStreamDefault('subj');
                end
            end
            
            % procResult
            if isproperty(S,'procResult') && ~isempty(S.procResult)
                obj.procResult = copyStructFieldByField(obj.procResult, S.procResult);
            end
            
            % CondNames
            if isproperty(S,'CondNames') && ~isempty(S.CondNames)
                obj.CondNames = copyStructFieldByField(obj.CondNames, S.CondNames);
            end
            
            % CondName2Run
            if isproperty(S,'CondName2Run') && ~isempty(S.CondName2Run)
                obj.CondName2Run = copyStructFieldByField(obj.CondName2Run, S.CondName2Run);
            end
                        
        end
        
        
        % ----------------------------------------------------------------------------------
        % Check whether run R exists in this subject and return
        % its index if it does exist. Else return 0.
        % ----------------------------------------------------------------------------------
        function j = existRun(obj, k, S)
            
            j=0;
            for i=1:length(S.runs)
                [sname1, ~, w1] = getSubjNameAndRun(obj.runs(k).name, i);
                [sname2, ~, w2] = getSubjNameAndRun(S.runs(i).name, i);
                rname1 = obj.runs(k).name;
                rname2 = S.runs(i).name;
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
                    group.subjs(obj.iRun) = obj;
                    save( './groupResults.mat','group' );
                end
            end
            
            % Save acquired data
            if options_s.acquired
                for ii=1:length(obj.runs)
                    obj.runs(ii).Save('acquired');
                end
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function SetSD(obj)
            
            obj.SD = obj.runs(1).GetSD();
            
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSD(obj)
            
            SD = obj.runs(1).GetSD();
            
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
        function ch = GetMeasList(obj)
            
            ch = obj.runs(1).GetMeasList();
            
        end
                
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            
            wls = obj.runs(1).GetWls();
            
        end
        
        % ----------------------------------------------------------------------------------
        function SetCondNames(obj)
            
            CondNames = {};
            for ii=1:length(obj.runs)
                obj.runs(ii).SetCondNames();
                CondNames = [CondNames, obj.runs(ii).GetCondNames()];
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
            obj.CondName2Run = zeros(length(obj.runs), length(obj.CondNames));
            for iC=1:length(obj.CondNames)
                for iRun=1:length(obj.runs)
                    k = find(strcmp(obj.CondNames{iC}, obj.runs(iRun).GetCondNames()));
                    if isempty(k)
                        obj.CondName2Run(iRun,iC) = 0;
                    else
                        obj.CondName2Run(iRun,iC) = k(1);
                    end
                end
            end
                        
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNameIdx = GetCondNameIdx(obj, CondNameIdx)
            
            CondNameIdx = find(obj.CondName2Group == CondNameIdx);
            
        end
        
    end       % Public Set/Get methods
        
end
