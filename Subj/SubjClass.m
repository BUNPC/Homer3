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
        
        
        % -------------------------------------------------
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
        
        
    end
    
end