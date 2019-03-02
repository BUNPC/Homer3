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
            idx = obj.igroup;
        end

        
        % ----------------------------------------------------------------
        function idx = IdxSubj(obj)
            idx = obj.isubj;
        end
        
            
        % ----------------------------------------------------------------
        function idx = IdxRun(obj)
            idx = obj.irun;
        end
            
   
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return
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
            for ii=1:length(obj.funcReg)
                usagename = obj.funcReg(ii).GetUsageName(fcall);
                if ~isempty(usagename)
                    break;
                end
            end            
        end
       
    end
end