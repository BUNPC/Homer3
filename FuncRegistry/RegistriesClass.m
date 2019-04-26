classdef RegistriesClass < handle
    
    properties
        userfuncdir
        igroup
        isubj
        irun
        funcReg
        config        
        filename;
    end
    
    methods
        
        % ----------------------------------------------------------------
        function obj = RegistriesClass(mode)
            %
            % Class containing an array of registries named 'group', 
            % 'subj', and 'run'
            %
            %

            % Added mode argument to allow 'empty' option to avoid loading 
            % registry but make the methods AND config options available. 
            % This is useful for deleting saved Registry.mat when unit testing.
            if nargin==0
                mode = 'normal';
            end
            
            obj.igroup = 1;
            obj.isubj = 2;
            obj.irun = 3;
            obj.funcReg = FuncRegClass().empty();
            obj.filename = '';

            % Get the parameter items from config file relevant to this class
            obj.config = struct('InclArchivedFunctions','');
            cfg = ConfigFileClass();
            obj.config.InclArchivedFunctions = cfg.GetValue('Include Archived User Functions');
            obj.userfuncdir = FindUserFuncDir(obj);
            
            if strcmp(mode, 'empty')
                return;
            end
            
            % Check if saved registry exists. If so load that and exit
            if exist([obj.userfuncdir{1}, 'Registry.mat'], 'file')
                obj.filename = [obj.userfuncdir{1}, 'Registry.mat'];
                r = load(obj.filename, 'reg');
                if isa(r.reg, 'RegistriesClass') && ~isempty(r.reg)
                    obj.Copy(r.reg);
                    return;
                end
            end
            
            obj.funcReg(obj.igroup) = FuncRegClass('group');
            obj.funcReg(obj.isubj) = FuncRegClass('subj');
            obj.funcReg(obj.irun) = FuncRegClass('run');
            
            % Save registry for next time
            obj.Save();
            
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj)
            reg = obj;
            save([obj.userfuncdir{1}, 'Registry.mat'], 'reg');
        end
        
        
        % -------------------------------------------------------------------------------
        function err = AddEntry(obj, funcname)
            switch(funcname(1:5))
                case 'hmrG_'
                    itype = obj.igroup;
                case 'hmrS_'
                    itype = obj.isubj;
                case 'hmrR_'
                    itype = obj.irun;
                otherwise
                    err = 1;
                    return;
            end
            err = obj.funcReg(itype).AddEntry(funcname);
        end
        
        
        % -------------------------------------------------------------------------------
        function err = ReloadEntry(obj, funcname)                      
            switch(funcname(1:5))
                case 'hmrG_'
                    itype = obj.igroup;
                case 'hmrS_'
                    itype = obj.isubj;
                case 'hmrR_'
                    itype = obj.irun;
                otherwise
                    err = 1;
                    return;
            end
            err = obj.funcReg(itype).ReloadEntry(funcname);
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteSaved(obj)
            if exist([obj.userfuncdir{1}, 'Registry.mat'], 'file')
                delete([obj.userfuncdir{1}, 'Registry.mat']);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            obj.igroup = obj2.igroup;
            obj.isubj = obj2.isubj;
            obj.irun = obj2.irun;
            for ii=1:length(obj2.funcReg)
                obj.funcReg(ii) = FuncRegClass(obj2.funcReg(ii));
            end
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
       
        
        
        % ----------------------------------------------------------------------------------
        function fname = GetSavedRegistryPath(obj)
            fname = obj.filename;
        end
               
    end
end

