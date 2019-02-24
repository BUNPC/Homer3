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
        function t = GetTHRF(obj)
            t = obj.tHRF;
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvg = GetDodAvg(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dodAvg, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dodAvg,3);
                end
            end
            if isa(obj.dodAvg, 'handle')
                dodAvg = [];
            else
                if isempty(obj.dodAvg)
                    dodAvg = [];
                    return
                end
                dodAvg = obj.dodAvg(:,:,condition);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvg = GetDcAvg(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dcAvg, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dcAvg,4);
                end
            end
            if isa(obj.dcAvg, 'handle')
                dcAvg = [];
            else
                if isempty(obj.dcAvg)
                    dcAvg = [];
                    return
                end
                dcAvg = obj.dcAvg(:,:,:,condition);
            end
        end

        
        % ----------------------------------------------------------------------------------
        function dodAvgStd = GetDodAvgStd(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dodAvgStd, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dodAvgStd,3);
                end
            end
            if isa(obj.dodAvgStd, 'handle')
                dodAvgStd = [];
            else
                if isempty(obj.dodAvgStd)
                    dodAvgStd = [];
                    return
                end
                dodAvgStd = obj.dodAvgStd(:,:,condition);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvgStd = GetDcAvgStd(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dcAvgStd, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dcAvgStd,4);
                end
            end
            if isa(obj.dcAvgStd, 'handle')
                dcAvgStd = [];
            else
                if isempty(obj.dcAvgStd)
                    dcAvgStd = [];
                    return
                end
                dcAvgStd = obj.dcAvgStd(:,:,:,condition);
            end
        end

        
        % ----------------------------------------------------------------------------------
        function dodSum2 = GetDodSum2(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dodSum2, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dodSum2,3);
                end
            end
            if isa(obj.dodSum2, 'handle')
                dodSum2 = [];
            else
                if isempty(obj.dodSum2)
                    dodSum2 = [];
                    return
                end
                dodSum2 = obj.dodSum2(:,:,condition);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcSum2 = GetDcSum2(obj, condition)
            if ~exist('condition','var')
                if isa(obj.dodSum2, 'handle')
                    condition = 1;
                else
                    condition = 1:size(obj.dcSum2,4);
                end
            end
            if isa(obj.dcSum2, 'handle')
                dcSum2 = [];
            else
                if isempty(obj.dcSum2)
                    dcSum2 = [];
                    return
                end
                dcSum2 = obj.dcSum2(:,:,:,condition);
            end
        end

        
        % ----------------------------------------------------------------------------------
        function dod = GetDod(obj)
            if isa(obj.dod, 'handle')
                dod = [];
            else
                dod = obj.dod;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function dc = GetDc(obj)
            if isa(obj.dc, 'handle')
                dc = [];      % Place holder to be implemented later
            else
                dc = obj.dc;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function nTrials = GetNtrials(obj)
            nTrials = obj.nTrials;
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function copy(obj, objnew)
            fields = properties(obj);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(objnew, ''%s'')', fields{ii}))
                    continue;
                end
                if eval(sprintf('strcmp(objnew.%s, ''misc'')', fields{ii}))
                    continue;
                end
                prop = sprintf('obj.%s', fields{ii});
                if isa(eval(prop), 'handle')
                    sprintf('obj.%s = objnew.%s.copy()', prop, prop);
                else
                    sprintf('obj.%s = objnew.%s', prop, prop);
                end
            end
            
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(objnew.misc, ''%s'')', fields{ii}))
                    continue;
                end
                prop = sprintf('obj.misc.%s', fields{ii});
                if isa(eval(prop), 'handle')
                    sprintf('obj.%s = objnew.misc.%s.copy()', prop, prop);
                else
                    sprintf('obj.%s = objnew.misc.%s', prop, prop);
                end
            end
        end
        
        
    end
     
end