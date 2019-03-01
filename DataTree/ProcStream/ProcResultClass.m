classdef ProcResultClass < handle
    
    properties
        dod;
        dc;
        dodAvg;
        dcAvg;
        dodAvgStd;
        dcAvgStd;
        dodSum2;
        dcSum2;
        tHRF;
        nTrials;
        ch;
        grpAvgPass;
        misc;
    end
    
    methods
        
        % ---------------------------------------------------------------------------
        function obj = ProcResultClass()
            obj.Initialize();
        end
        
        
        % ---------------------------------------------------------------------------
        function Initialize(obj)
            obj.dod = [];
            obj.dc = [];
            obj.dodAvg = [];
            obj.dcAvg = [];
            obj.dodAvgStd = [];
            obj.dcAvgStd = [];
            obj.dodSum2 = [];
            obj.dcSum2 = [];
            obj.tHRF = [];
            obj.nTrials = [];
            obj.ch = [];
            obj.grpAvgPass = [];
            obj.misc = [];
        end
             
        
        % ---------------------------------------------------------------------------
        function SettHRFCommon(obj, tHRF_common, name, type)
            if size(tHRF_common,2)<size(tHRF_common,1)
                tHRF_common = tHRF_common';
            end
            tHRF = obj.tHRF;
            n = length(tHRF_common);
            m = length(tHRF);
            d = n-m;
            if d<0
                fprintf('WARNING: tHRF for %s %s is larger than the common tHRF.\n',type, name);
                if ~isempty(obj.dodAvg)
                    obj.dodAvg(n+1:m,:,:)=[];
                    if strcmp(type,'run')
                        obj.dodSum2(n+1:m,:,:)=[];
                    end
                end
                if ~isempty(obj.dcAvg)
                    obj.dcAvg(n+1:m,:,:,:)=[];
                    if strcmp(type,'run')
                        obj.dcSum2(n+1:m,:,:,:)=[];
                    end
                end
            elseif d>0
                fprintf('WARNING: tHRF for %s %s is smaller than the common tHRF.\n',type, name);
                if ~isempty(obj.dodAvg)
                    obj.dodAvg(m:n,:,:)=zeros(d,size(obj.dodAvg,2),size(obj.dodAvg,3));
                    if strcmp(type,'run')
                        obj.dodSum2(m:n,:,:)=zeros(d,size(obj.dodSum2,2),size(obj.dodSum2,3));
                    end
                end
                if ~isempty(obj.dcAvg)
                    obj.dcAvg(m:n,:,:,:)=zeros(d,size(obj.dcAvg,2),size(obj.dcAvg,3),size(obj.dcAvg,4));
                    if strcmp(type,'run')
                        obj.dcSum2(m:m+d,:,:,:)=zeros(d,size(obj.dcSum2,2),size(obj.dcSum2,3),size(obj.dcSum2,4));
                    end
                end
            end
            obj.tHRF = tHRF_common;                                    
        end

        
        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
            elseif isproperty(obj.misc, varname)
                found = true;
            end
        end

        
        % ----------------------------------------------------------------------------------
        function var = GetVar(obj, varname)
            var = [];
            if isproperty(obj, varname)
                eval(sprintf('var = obj.%s;', varname));
            elseif isproperty(obj.misc, varname)
                eval(sprintf('var = obj.misc.%s;', varname));
            end
        end

        
        % ----------------------------------------------------------------------------------
        function Flush(obj)
            obj.Initialize();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 6;
            end
            fprintf('%sOutput:\n', blanks(indent));
            fprintf('%snTrials:\n', blanks(indent+4));
            pretty_print_matrix(obj.nTrials, indent+4, sprintf('%%d'))
        end
        
    end  
        
    
    
    methods
           
        % ----------------------------------------------------------------------------------
        function SetTHRF(obj, t)
            obj.tHRF = t;
        end
                
        % ----------------------------------------------------------------------------------
        function t = GetTHRF(obj)
            t = [];
            if isempty(obj.tHRF)
                if isa(obj.dcAvg, 'DataClass') && ~isempty(obj.dcAvg)
                    t = obj.dcAvg.GetT();
                elseif isa(obj.dodAvg, 'DataClass') && ~isempty(obj.dodAvg)
                    t = obj.dodAvg.GetT();                    
                end
            else
                t = obj.tHRF;
            end
        end

        % ----------------------------------------------------------------------------------
        function SetDodAvg(obj, val)
            obj.dodAvg = val;
        end
                    
        % ----------------------------------------------------------------------------------
        function SetDcAvg(obj, val)
            obj.dcAvg = val;
        end
        
            
        % ----------------------------------------------------------------------------------
        function SetDodAvgStd(obj, val)
            obj.dodAvgStd = val;
        end
                    
        % ----------------------------------------------------------------------------------
        function SetDcAvgStd(obj, val)
            obj.dcAvgStd = val;
        end
        
            
        % ----------------------------------------------------------------------------------
        function SetDodSum2(obj, val)
            obj.dodSum2 = val;
        end
                    
        % ----------------------------------------------------------------------------------
        function SetDcSum2(obj, val)
            obj.dcSum2 = val;
        end
        
            
        % ----------------------------------------------------------------------------------
        function SetDod(obj, val)
            obj.dod = val;
        end
                    
        % ----------------------------------------------------------------------------------
        function SetDc(obj, val)
            obj.dc = val;
        end
        
            
        % ----------------------------------------------------------------------------------
        function yavg = GetDodAvg(obj, type, condition)           
            yavg = [];
            
            % Check type argument 
            if ~exist('type','var') || isempty(type)
                type = 'dodAvg';
            end
            if ~ischar(type)
                return;
            end
            
            % Get data matrix
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                yavg       = eval(sprintf('obj.%s.GetDataMatrix()', type));
            else
                yavg       = eval(sprintf('obj.%s', type));
            end
            
            % Get condition
            if ~exist('condition','var') || isempty(condition)
                condition = 1:size(yavg,3);
            end
            if isempty(yavg)
                return;
            end
            yavg = yavg(:,:,condition);
        end

        
        
        % ----------------------------------------------------------------------------------
        function yavg = GetDcAvg(obj, type, condition)           
            yavg = [];
            
            % Check type argument 
            if ~exist('type','var') || isempty(type)
                type = 'dcAvg';
            end
            if ~ischar(type)
                return;
            end
            
            % Get data matrix
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                yavg  = eval(sprintf('obj.%s.GetDataMatrix()', type));
            else
                yavg = eval(sprintf('obj.%s', type));
            end
            
            % Get condition
            if ~exist('condition','var') || isempty(condition)
                condition = 1:size(yavg,4);
            end
            if isempty(yavg)
                return;
            end
            yavg = yavg(:,:,:,condition);
        end

        
        % ----------------------------------------------------------------------------------
        function y = GetDataTimeCourse(obj, type)
            y = [];
            
            % Check type argument 
            if ~exist('type','var') || isempty(type)
                type = 'dcAvg';
            end
            if ~ischar(type)
                return;
            end
            
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                y = eval(sprintf('obj.%s.GetDataMatrix()', type));
            else
                y = eval(sprintf('obj.%s', type));
            end
        end
                
        
        % ----------------------------------------------------------------------------------
        function SetNtrials(obj, val)
            obj.nTrials = val;
        end
        
        % ----------------------------------------------------------------------------------
        function nTrials = GetNtrials(obj)
            nTrials = obj.nTrials;
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            fields = properties(obj);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2, ''%s'')', fields{ii}))
                    continue;
                end
                if eval(sprintf('strcmp(obj2.%s, ''misc'')', fields{ii}))
                    continue;
                end
                if isa(eval(sprintf('obj.%s', fields{ii})), 'handle')
                    eval( sprintf('obj.%s.Copy(obj2.%s);', fields{ii}, fields{ii}) );
                else
                    eval( sprintf('obj.%s = obj2.%s;', fields{ii}, fields{ii}) );
                end
            end
            
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2.misc, ''%s'')', fields{ii}))
                    continue;
                end
                if isa(eval(sprintf('obj.misc.%s', fields{ii})), 'handle')
                    eval( sprintf('obj.misc.%s.Copy(obj2.misc.%s);', fields{ii}, fields{ii}) );
                else
                    eval( sprintf('obj.misc.%s = obj2.misc.%s;', fields{ii}, fields{ii}) );
                end
            end
        end
        
        
    end
     
end