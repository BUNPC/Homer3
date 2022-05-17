classdef RegistriesClass < handle
    
    properties
        userfuncdir
        igroup
        isubj
        isess
        irun
        funcReg
        config        
        filename;
    end
    
    methods
        
        % ----------------------------------------------------------------
        function obj = RegistriesClass(mode)
            %
            % Syntax:
            %   reg = RegistriesClass();
            %   reg = RegistriesClass('normal');
            %   reg = RegistriesClass('empty');
            %   reg = RegistriesClass('reload');
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
            obj.isess = 3;
            obj.irun = 4;
            obj.funcReg = FuncRegClass().empty();
            obj.filename = '';

            % Get the parameter items from config file relevant to this class
            obj.userfuncdir = FindUserFuncDir(obj);
            if isempty(obj.userfuncdir)
                return
            end
            if strcmp(mode, 'empty')
                return;
            end
            if strcmp(mode, 'reset')
                obj.DeleteSaved();
                return;
            end
            
            % Check if saved registry exists. If so load that and exit
            if ~strcmp(mode, 'reload')
                if exist([obj.userfuncdir{1}, 'Registry.mat'], 'file')
                    obj.filename = [obj.userfuncdir{1}, 'Registry.mat'];
                    r = load(obj.filename, 'reg');
                    if isa(r.reg, 'RegistriesClass') && ~isempty(r.reg)
                        obj.Copy(r.reg);
                        if obj.IsValid()
                            return;
                        end
                    end
                end
            end

            obj.Load();
            
            % Save registry for next time
            obj.Save();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Load(obj, type)
            if nargin==1
                type = 'all';
            end
            
            switch(type)
                case 'all'
                    obj.funcReg(obj.igroup) = FuncRegClass('group');
                    obj.funcReg(obj.isubj) = FuncRegClass('subj');
                    obj.funcReg(obj.isess) = FuncRegClass('sess',2);
                    obj.funcReg(obj.irun) = FuncRegClass('run');
                case 'group'
                    obj.funcReg(obj.igroup) = FuncRegClass('group');
                case 'subj'
                    obj.funcReg(obj.isubj) = FuncRegClass('subj');
                case 'sess'
                    obj.funcReg(obj.isess) = FuncRegClass('sess');
                case 'run'
                    obj.funcReg(obj.irun) = FuncRegClass('run');
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj)
            reg = obj;
            save([obj.userfuncdir{1}, 'Registry.mat'], 'reg');
        end
        
        
        % ----------------------------------------------------------------------------------
        function Reload(obj, type)
            if nargin==1
                type = 'all';
            end
            
            % Delete saved resistry file
            obj.DeleteSaved();
            
            % Reload and resave the registry
            obj.Load(type);
            obj.Save();
        end
        
        
        % -------------------------------------------------------------------------------
        function err = AddEntry(obj, funcname)
            switch(funcname(1:5))
                case 'hmrG_'
                    itype = obj.igroup;
                case 'hmrS_'
                    itype = obj.isubj;
                case 'hmrE_'
                    itype = obj.isess;
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
                case 'hmrE_'
                    itype = obj.isess;
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
            obj.isess = obj2.isess;
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
            
   
        % ----------------------------------------------------------------
        function idx = IdxSess(obj)
            idx=[];
            if isempty(obj)
                return;
            end
            idx = obj.isess;
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
        function fcall = GetFuncCallDecoded(obj, key, usagename)
            fcall = FuncCallClass().empty();
            if isempty(obj)
                return;
            end
            if nargin<3
                return;
            end
            for ii=1:length(obj.funcReg)
                fcall = obj.funcReg(ii).GetFuncCallDecoded(key, usagename);
                if ~isempty(fcall)
                    break;
                end
            end
        end
       
        
        % ----------------------------------------------------------------------------------
        function fcall = FindClosestMatch(obj, fcall0)
            fcall = FuncCallClass().empty();
            if isempty(obj)
                return;
            end
            if nargin<2
                return;
            end
            for ii=1:length(obj.funcReg)
                fcall = obj.funcReg(ii).FindClosestMatch(fcall0);
                if ~isempty(fcall)
                    break;
                end
            end
        end
       
        
        % ----------------------------------------------------------------------------------
        function fname = GetSavedRegistryPath(obj)
            fname = obj.filename;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function n = GetNumUsages(obj, funcname)
            n = [];
            if isempty(obj)
                return;
            end
            if nargin<2
                return;
            end
            for ii = 1:length(obj.funcReg)
                n = obj.funcReg(ii).GetNumUsages(funcname);
                if n>0
                    break;
                end
            end
        end
       
        
        
        % ----------------------------------------------------------------------------------
        function Import(obj, funcpath)
            [~, fname, ext] = fileparts(funcpath);            
            if exist([obj.userfuncdir{1}, fname, ext], 'file') == 2
                q = MenuBox('Function already exists in Registry folder. Do you want to replece it',{'Yes','No'});
                if q==2
                    return;
                end
            end
            copyfile(funcpath, obj.userfuncdir{1});
            if strncmp(fname, 'hmrG_', 5)
                type = 'group';
            elseif strncmp(fname, 'hmrS_', 5)
                type = 'subj';
            elseif strncmp(fname, 'hmrE_', 5)
                type = 'sess';
            elseif strncmp(fname, 'hmrR_', 5)
                type = 'run';
            else
                type = 'all';
            end
            obj.Reload(type);
        end
    
        
        % ----------------------------------------------------------------------------------
        function b = IsValid(obj)
            b = false;
            regfile = dir([obj.userfuncdir{1}, 'Registry.mat']);
            for ii = 1:length(obj.funcReg)
                try
                    if obj.funcReg(ii).DateLastModified() > datetime(regfile.date,'locale','system')
                        return;
                    end
                catch
                    % pass
                end
            end
            b = true;
        end
        

        % ----------------------------------------------------------------------------------
        function entry = GetEntryByName(obj, entry_name)
            entry = [];
            for i=1:size(obj.funcReg, 2)
                for j=1:size(obj.funcReg(i).entries, 2)
                    if strcmp(obj.funcReg(i).entries(j).name, entry_name) || strcmp(obj.funcReg(i).entries(j).uiname, entry_name)
                        entry = obj.funcReg(i).entries(j);
                    end
                end
            end
        end
        
    end
        
end

