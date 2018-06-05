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
        
        
        % -------------------------------------------------
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
            if isproperty(run0,'tIncMan')
                obj.tIncMan    = run0.tIncMan;
            end
            if isproperty(run0,'CondNames')
                obj.CondNames  = run0.CondNames;
            end
            if isproperty(run0,'CondRun2Group')
                obj.CondRun2Group = run0.CondRun2Group;
            end
            if isproperty(run0,'userdata')
                obj.userdata   = run0.userdata;
            end
            if isproperty(run0,'procInput')
                obj.procInput  = procStreamCopy2Native(run0.procInput);
            end
            if isproperty(run0,'procResult')
                obj.procResult = run0.procResult;
            end
                                
        end
        
    end
    
end