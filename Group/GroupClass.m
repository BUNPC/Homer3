classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        
        fileidx;
        nFiles;
        CondGroup2Subj;
        CondColTbl;
        subjs;
        
    end
    
    methods
        
        
        % -------------------------------------------------
        function obj = GroupClass(varargin)
            
            if nargin>0
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
            obj.CondGroup2Subj = [];
            obj.CondColTbl = [];
            obj.subjs = subj;
            
        end

        
        
        % -------------------------------------------------
        function CopyProcInput(obj, varargin)
            
            procInput = InitProcInput();
            
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
        
        
    end
    
end


