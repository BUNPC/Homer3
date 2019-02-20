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
        
          
        % ----------------------------------------------------------------------------------
        function t = GetTHRF(obj)
            t = obj.tHRF;
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvg = GetDodAvg(obj, condition)
            if ~exist('condition','var')
                condition = 1:size(obj.dodAvg,3);
            end
            dodAvg = obj.dodAvg(:,:,condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvg = GetDcAvg(obj, condition)
            if ~exist('condition','var')
                condition = 1:size(obj.dcAvg,4);
            end
            dcAvg = obj.dcAvg(:,:,:,condition);
        end
                  
    end
     
end