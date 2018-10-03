classdef RunClass < TreeNodeClass
    
    properties % (Access = private)
        
        iSubj;
        iRun;
        rnum;
        t;
        s;
        d;
        aux;
        tIncMan;
        CondRun2Group;
        userdata;
        
    end
    
    methods
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = RunClass(varargin)
            
            if nargin==4
                filename = varargin{1};
                iSubj    = varargin{2};
                iRun     = varargin{3};
                rnum     = varargin{4};
            else
                return;
            end
            
            obj.iSubj = 0;
            obj.iRun = 0;
            obj.rnum = 0;
            obj.t = [];
            obj.s = [];
            obj.d = [];
            obj.aux = [];
            obj.tIncMan = [];
            obj.CondRun2Group = [];
            obj.userdata = struct([]);
            
            run0 = loadRun(filename);
            
            obj.name       = filename;
            obj.type       = 'run';
            obj.iSubj      = iSubj;
            obj.iRun       = iRun;
            obj.rnum       = rnum;
            if isproperty(run0,'SD')
                obj.SD         = run0.SD;
            end
            if isproperty(run0,'t')
                obj.t          = run0.t;
            end
            if isproperty(run0,'s')
                obj.s          = run0.s;
            end
            if isproperty(run0,'d')
                obj.d          = run0.d;
            end
            if isproperty(run0,'aux')
                obj.aux        = run0.aux;
            end
            if isproperty(run0,'CondNames')
                obj.CondNames  = run0.CondNames;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % N2 to N1 if N1 and N2 are same nodes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function copyProcParams(obj, R)
            
            if obj == R
                obj.copyProcParamsFieldByField(R);
            end
            
        end
   
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % N2 to N1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function copyProcParamsFieldByField(obj, R)

            % procInput
            if isproperty(R,'procInput')
                if isproperty(R.procInput,'procFunc') && ~isempty(R.procInput.procFunc)
                    obj.procInput.Copy(R.procInput);
                else
                    [obj.procInput.procFunc, obj.procInput.procParam] = procStreamDefault('run');
                end
            end
            
            % procResult
            if isproperty(R,'procResult') && ~isempty(R.procResult)
                obj.procResult = copyStructFieldByField(obj.procResult, R.procResult);
            end
            
            % CondNames
            if isproperty(R,'CondNames') && ~isempty(R.CondNames)
                obj.CondNames = copyStructFieldByField(obj.CondNames, R.CondNames);
            end
            
            % CondSubj2Run
            if isproperty(R,'CondRun2Group') && ~isempty(R.CondRun2Group)
                obj.CondRun2Group = copyStructFieldByField(obj.CondRun2Group, R.CondRun2Group);
            end
            
            % tIncMan
            if isproperty(R,'tIncMan') && ~isempty(R.tIncMan)
                obj.tIncMan = copyStructFieldByField(obj.tIncMan, R.tIncMan);
            end
            
            % userdata
            if isproperty(R,'userdata') && ~isempty(R.userdata)
                obj.userdata = copyStructFieldByField(obj.userdata, R.userdata);
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
            
        end
        
    end
    
end
