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
        function obj = ProcResultClass
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
        
    end
     
end