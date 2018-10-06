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
            
            obj.name  = filename;
            obj.type  = 'run';
            obj.iSubj = iSubj;
            obj.iRun  = iRun;
            obj.rnum  = rnum;

            obj.t       = [];
            obj.s       = [];
            obj.d       = [];
            obj.aux     = [];
            obj.tIncMan = [];
            obj.userdata = [];
            obj.CondRun2Group = [];
            
            obj.Load();
                        
        end
        

        
        % ---------------------------------------------------------
        function [paramsStr, paramsLst] = getParamsStr(obj, paramsLst)
            
            paramsLstReadOnly  = {'d','aux'};
            paramsLstReadWrite = {'t','SD','s','CondNames'};
            paramsLstAll = [paramsLstReadOnly, paramsLstReadWrite];
            
            % Determine the preliminary list of params
            if isempty(paramsLst)
                paramsLst = paramsLstReadWrite;
            end
            
            for ii=1:length(paramsLstAll)
                
                if ~ismember(paramsLstAll{ii}, paramsLst) & ~isprop(obj, paramsLstAll{ii}) & ismember(paramsLstAll{ii},paramsLstReadWrite)
                    paramsLst{end+1} = paramsLstAll{ii};
                end
                if ~ismember(paramsLstAll{ii}, paramsLst)  & isprop(obj, paramsLstAll{ii}) & eval(sprintf('obj.isemptyParam(obj.%s)',paramsLstAll{ii}))
                    paramsLst{end+1} = paramsLstAll{ii};
                end
                
            end
            
            % Convert final list of params to single string
            paramsStr='';
            for ii=1:length(paramsLst)
                paramsStr = strcat(paramsStr,['''' paramsLst{ii} '''']);
                if ii<length(paramsLst)
                    paramsStr = strcat(paramsStr,',');
                end
            end
            
        end
           
        
        % ---------------------------------------------------------
        function b = isemptyParam(obj, param)
            
            b=1;
            if isstruct(param)
                
                fields=fieldnames(param);
                for ii=1:length(fields)
                    if eval(sprintf('~isempty(param.%s);', fields{ii}))
                        b=0;
                    end
                end
                
            elseif ~isempty(param)
                
                b=0;
                
            end
            
        end
        
        
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Load(obj, paramsLst)
            
            if isempty(obj.name) || ~exist(obj.name, 'file')
                return;
            end

            if ~exist('paramsLst','var')
                paramsLst = [];
            end
            
            warning('off', 'MATLAB:load:variableNotFound');
                       
            [paramsStr, paramsLst] = obj.getParamsStr(paramsLst);
            eval(sprintf('fdata = load(obj.name,''-mat'', %s);', paramsStr));
                        
            if isproperty(fdata,'d')
                obj.d = fdata.d;
            elseif ismember('d', paramsLst)
                obj.d = [];
            end
            
            if isproperty(fdata,'t')
                obj.t = fdata.t;
            elseif ismember('t', paramsLst)
                obj.t = [];
            end
            
            if isproperty(fdata,'SD')
                obj.SD = SetSDRun(fdata.SD);
            elseif ismember('SD', paramsLst)
                obj.SD = struct([]);
            end
            
            if isproperty(fdata,'s')
                obj.s = fdata.s;
            elseif ismember('s',paramsLst)
                obj.s = [];
            end
            
            if isproperty(fdata,'aux')
                obj.aux = fdata.aux;
            elseif ismember('aux',paramsLst)
                obj.aux = [];
            end
            
            if isproperty(fdata,'CondNames')
                obj.CondNames = fdata.CondNames;
            elseif ismember('CondNames', paramsLst) && ~isproperty(fdata,'CondNames')
                obj.InitCondNames();
            end
            
            warning('on', 'MATLAB:load:variableNotFound');
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Save(obj, options)
            
            if ~exist('options','var')
                options = 'acquired:derived';
            end
            options_s = obj.parseSaveOptions(options);
            
            % Save derived data
            if options_s.derived
                if exist('./groupResults.mat','file')
                    load( './groupResults.mat' );
                    group.subjs(obj.iSubj).runs(obj.iRun) = obj;
                    save( './groupResults.mat','group' );
                end
            end
            
            % Save acquired data
            if options_s.acquired
                ;
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nTrials = InitCondNames(obj)
            
            if isempty(obj.CondNames)
                obj.CondNames = repmat({''},1,size(obj.s,2));
            end
            
            for ii=1:size(obj.s,2)
                
                if isempty(obj.CondNames{ii})
                    
                    % Make sure not to duplicate a condition name
                    jj=0;
                    kk=ii+jj;
                    condName = num2str(kk);
                    while ~isempty(find(strcmp(condName, obj.CondNames)))
                        jj=jj+1;
                        kk=ii+jj;
                        condName = num2str(kk);
                    end
                    obj.CondNames{ii} = condName;
                    
                else
                    
                    % Check if CondNames{ii} has a name. If not name it but
                    % make sure not to duplicate a condition name
                    k = find(strcmp(obj.CondNames{ii}, obj.CondNames));
                    if length(k)>1
                        % Unname and then rename duplicate condition
                        obj.CondNames{ii} = '';
                        
                        jj=0;
                        while find(strcmp(num2str(ii), obj.CondNames))
                            kk=ii+jj;
                            obj.CondNames{ii} = num2str(kk);
                            jj=jj+1;
                        end
                    end
                    
                end
                
            end
            
            nTrials = sum(obj.s,1);
            
        end
    end

end
