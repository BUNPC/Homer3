classdef GroupClass < TreeNodeClass
    
    properties % (Access = private)
        
        fileidx;
        nFiles;
        CondGroup2Subj;
        CondColTbl;
        subjs;
        
    end
    
    %%%% Public methods 
    methods
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Groups obj1 and obj2 are considered equivalent if their names
        % are equivalent and their subject sets are equivalent.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function OverwriteProcInput(obj, varargin)
            
            % Overwrite procInput of group tree members of a single level
            % (ie., group, subject, run)
            
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CopyProcInput(obj, varargin)
            
            % Copy procInput only to those group tree members at a single level
            % (ie., group, subject, run) with empty procInput
            
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            
            
            %%%%% Otherwise try loading procInput from a config file, but first
            %%%%% figure out the name of the config file
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CopySD(obj)
            
            for jj=1:length(obj.subjs)
                if isempty(obj.subjs(jj).SD)
                    obj.subjs(jj).SD = SetSDSubj(obj.subjs(jj).runs(1).SD);
                end
            end
            if isempty(obj.SD)
                obj.SD = SetSDGroup(obj.subjs(1).SD);
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function LoadGroupFile(obj, files)
            
            if exist('./groupResults.mat','file')
                
                load( './groupResults.mat' );
                
                % copy procResult from previous group to current group for
                % all nodes that still exist in the current group.
                hwait = waitbar(0,'Loading group');
                obj.copyProcParams(group);
                close(hwait);
                
            end
            
        end        
        
    end  % Public methods
    
    
    %%%% Private methods 
    methods  (Access = {})
                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % N2 to obj if obj and N2 are equivalent nodes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Copy processing params (procInut and procResult) from
        % G to obj
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function copyProcParamsFieldByField(obj, G)
            
            % procInput
            if isproperty(G,'procInput') && ~isempty(G.procInput)
                if isproperty(G.procInput,'procFunc') && ~isempty(G.procInput.procFunc)
                    obj.procInput = copyStructFieldByField(obj.procInput, G.procInput);
                else
                    [obj.procInput.procFunc, obj.procInput.procParam] = procStreamDefault('group');
                end
            end
            
            % procResult
            if isproperty(G,'procResult') && ~isempty(G.procResult)
                obj.procResult = copyStructFieldByField(obj.procResult, G.procResult);
            end
            
            % CondNames
            if isproperty(G,'CondNames') && ~isempty(G.CondNames)
                obj.CondNames = copyStructFieldByField(obj.CondNames, G.CondNames);
            end
            
            % CondGroup2Subj
            if isproperty(G,'CondGroup2Subj') && ~isempty(G.CondGroup2Subj)
                obj.CondGroup2Subj = copyStructFieldByField(obj.CondGroup2Subj, G.CondGroup2Subj);
            end
            
            % SD
            if isproperty(G,'SD') && ~isempty(G.SD)
                obj.SD = copyStructFieldByField(obj.SD, G.SD);
            end

        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check whether subject k'th subject from this group exists in group G and return
        % its index in G if it does exist. Else return 0.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

