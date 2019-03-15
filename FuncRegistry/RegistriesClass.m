classdef RegistriesClass < handle
    
    properties
        igroup
        isubj
        irun
        funcReg
    end
    
    methods
        
        % ----------------------------------------------------------------
        function obj = RegistriesClass()
            %
            % Class containing an array of registries named 'group', 
            % 'subj', and 'run'
            %
            %
            obj.igroup = 1;
            obj.isubj = 2;
            obj.irun = 3;
            
            obj.funcReg = FuncRegClass().empty();

            obj.funcReg(obj.igroup) = FuncRegClass('group');
            obj.funcReg(obj.isubj) = FuncRegClass('subj');
            obj.funcReg(obj.irun) = FuncRegClass('run');
        end
        
        
        % ----------------------------------------------------------------
        function idx = IdxGroup(obj)
            idx=[];
            if isempty(obj)
                return;
            end
            idx = obj.igroup;
        end

        
        % ----------------------------------------------------------------
        function idx = IdxSubj(obj)
            idx=[];
            if isempty(obj)
                return;
            end
            idx = obj.isubj;
        end
        
            
        % ----------------------------------------------------------------
        function idx = IdxRun(obj)
            idx=[];
            if isempty(obj)
                return;
            end
            idx = obj.irun;
        end
            
   
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.funcReg)
                return;
            end
            if obj.funcReg(obj.irun).IsEmpty()
                return;
            end
            b = false;            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function usagename = GetUsageName(obj, fcall)
            usagename = '';
            if isempty(obj)
                return;
            end
            if nargin<2
                return;
            end
            for ii=1:length(obj.funcReg)
                usagename = obj.funcReg(ii).GetUsageName(fcall);
                if ~isempty(usagename)
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagenames = GetUsageNames(obj, funcname)
            usagenames = {};
            if isempty(obj)
                return;
            end
            if nargin<2
                return;
            end
            for ii=1:length(obj.funcReg)
                usagenames = obj.funcReg(ii).GetUsageNames(funcname);
                if ~isempty(usagenames)
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcallstr = GetFuncCallStrDecoded(obj, key, usagename)
            fcallstr = '';
            if isempty(obj)
                return;
            end
            if nargin<3
                return;
            end
            for ii=1:length(obj.funcReg)
                fcallstr = obj.funcReg(ii).GetFuncCallStrDecoded(key, usagename);
                if ~isempty(fcallstr)
                    break;
                end
            end
        end
       
    end
end

