classdef SubjClass < TreeNodeClass
    
    properties % (Access = private)
        
        iSubj;
        iRun;
        rnum;
        CondSubj2Run;
        CondSubj2Group;
        runs;
        
    end
    
    methods
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SubjClass(varargin)
            
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
            obj.CondSubj2Run = [];
            obj.CondSubj2Group = [];
            obj.iSubj = iSubj;
            obj.runs = run;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % S to obj if obj and S are equivalent nodes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % S to obj
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            
            % CondSubj2Run
            if isproperty(S,'CondSubj2Run') && ~isempty(S.CondSubj2Run)
                obj.CondSubj2Run = copyStructFieldByField(obj.CondSubj2Run, S.CondSubj2Run);
            end
            
            % SD
            if isproperty(S,'SD') && ~isempty(S.SD)
                obj.SD = copyStructFieldByField(obj.SD, S.SD);
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check whether run R exists in this subject and return
        % its index if it does exist. Else return 0.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of runs are equivalent. 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
    end
    
end
