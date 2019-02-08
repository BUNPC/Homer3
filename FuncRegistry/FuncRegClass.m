classdef FuncRegClass < matlab.mixin.Copyable

    properties
        userfuncdir
        userfuncfiles       
        entries
        type
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegClass(type)
            % 
            % Syntax:
            %    obj = FuncRegClass(type);
            % 
            % Description:
            %    Generates a list of FuncRegEntryClass objects of type
            %    'run', 'subj', or 'group' for any hmr* user files it finds
            %    in the folder <Rootdir>/FuncRegistry/UserFunctions.
            %    <Rootdir> is relative to the location of this file,
            %    FuncRegClass.m
            % 
            % Example:  
            %    Generate array of registry entries for all run-level users
            %    functions
            % 
            %    freg = FuncRegClass('run')
            %
            %         ===> FuncRegClass with properties:
            %
            %         userfuncdir: 'c:/jdubb/workspaces/homer3/FuncRegistry/UserFunctions/'
            %       userfuncfiles: {1x10 cell}
            %             entries: [1x10 FuncRegEntryClass]
            %                type: 'run'
            % 
            %    freg.entries(1)
            %
            %         ===> FuncRegEntryClass with properties:
            %
            %                name: 'hmrR_BandpassFilt'
            %              uiname: 'Bandpass_Filter'
            %        usageoptions: {'Bandpass_Filter'  'dod = hmrR_BandpassFilt( dod, t, hpf, lpf )'  'hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500'}
            %              params: {2x2 cell}
            %                help: [1x1 FuncHelpClass]
            %
            if nargin==0
                return;
            end            
            obj.type = type;
            obj.entries = FuncRegEntryClass().empty();
            obj.userfuncdir = obj.FindUserFuncDir();
            obj.userfuncfiles = [];
            obj.Load();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Load(obj)            
            expr = sprintf('%shmr%s_*.m', obj.userfuncdir, upper(obj.type(1)));
            files = dir(expr);
            
            kk=1;
            for ii=1:length(files)
                if strfind(files(ii).name, '_result.m')
                    continue;
                end
                obj.entries(kk) = FuncRegEntryClass(files(ii).name);
                obj.userfuncfiles{kk} = [obj.userfuncdir, files(ii).name];
                kk=kk+1;
            end
        end
        
               
        % ----------------------------------------------------------------------------------
        function userfuncdir = FindUserFuncDir(obj)
            userfuncdir = '';
            if isdeployed()
                if ispc
                    userfuncdir = 'c:/Users/Public/homer3/FuncRegistry/UserFunctions/';
                elseif ismac()
                    userfuncdir = '~/homer3/FuncRegistry/UserFunctions/';
                end
            else
                srcdir = fileparts(which('FuncRegClass.m'));
                if exist([srcdir, '/UserFunctions']', 'dir')
                    userfuncdir = fullpath([srcdir, '/UserFunctions/']);
                elseif exist([srcdir, '/../UserFunctions']', 'dir')
                    userfuncdir = fullpath([srcdir, '/../UserFunctions/']);
                end
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return
            end
            if isempty(obj.userfuncdir)
                return;
            end
            if isempty(obj.userfuncfiles)
                return;
            end
            if isempty(obj.entries)
                return;
            end
            b = false;            
        end

        
        % ------------------------------------------------------
        function idx = GetIdx(obj, key)
            idx = [];
            if ~exist('key','var') || isempty(key)
                key = 1;
            end
            if ischar(key)
                k = [];
                for ii=1:length(obj.entries)
                    if strcmp(obj.entries(ii).GetName(), key)
                        k = ii;
                        break;
                    end
                end
                if isempty(k)
                    return
                end
                key = k(1);
            end
            if ~iswholenum(key) || key<1 || key>length(obj.entries)
                return;
            end
            idx = key;
        end        
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods to retrieve all or multiple entries 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function usagestrs = GetUsageStrs(obj, addnewline)
            if ~exist('addnewline','var')
                addnewline = 0;
            end
            if addnewline
                nl = newline();
            else
                nl = '';
            end
            usagestrs = cell(2*length(obj.entries), 1);
            kk = 1;
            for ii=1:length(obj.entries)
                for jj=1:obj.entries(ii).GetOptionsNum()
                    usagestrs{kk} = sprintf('@ %s%s', obj.entries(ii).GetUsageStr(jj), nl);
                    kk=kk+1;
                end
            end
            % Remove extra empty cells 
            usagestrs = usagestrs(~cellfun('isempty',usagestrs));
        end
                
        
        % ----------------------------------------------------------------------------------
        function names = GetFuncNames(obj)
            names = cell(length(obj.entries), 1);
            for ii=1:length(obj.entries)
                names{ii} = obj.entries(ii).GetName();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcallsstr = GetFuncCallsEncoded(obj, procInput)
            fcallsstr = {};
            if ~isa(fcall,'FuncCallClass')
                return
            end
            if isempty(procInput)
                return;
            end
            fcalls = procInput.fcalls;
            kk=1;
            for iFcall=1:length(fcalls)
                idx = obj.GetIdx(fcall(iFcall).GetName());
                if isempty(idx)
                    continue;
                end
                str = obj.entries(idx).GetFuncCallsEncoded(fcall(iFcall));
                if ~isempty(str)
                    fcallsstr{kk} = str;
                    kk=kk+1;
                end
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods to retrieve individual entries 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function [name, idx] = GetFuncName(obj, key)
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            name = obj.entries(idx).GetName();
        end

        
        % ----------------------------------------------------------------------------------
        function helpstr = GetFuncHelp(obj, key)
            helpstr = '';
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            helpstr = obj.entries(idx).GetHelpStr();
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcallstr = GetFuncCallStrDecoded(obj, key, usagename)
            usagestr = '';
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            fcallstr = obj.entries(idx).GetFuncCallStrDecoded(usagename);
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcall = GetFuncCallDecoded(obj, key, usagename)
            fcall = FuncCallClass().empty();
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            fcall = obj.entries(idx).GetFuncCallDecoded(usagename);
        end
        
        
        % ----------------------------------------------------------------------------------
        function paramtxt = GetParamText(obj, key)
            paramtxt = '';
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            paramtxt = obj.entries(idx).GetParamText();
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagename = GetUsageName(obj, fcall)
            usagename = '';
            if ~isa(fcall,'FuncCallClass')
                return
            end
            idx = obj.GetIdx(fcall.GetName());
            if isempty(idx)
                return;
            end
            usagename = obj.entries(idx).GetUsageName(fcall);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function usagenames = GetUsageNames(obj, funcname)
            usagenames = '';
            idx = obj.GetIdx(funcname);
            if isempty(idx)
                return;
            end
            usagenames = obj.entries(idx).GetUsageNames();
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagestr = GetUsageStrDecorated(obj, funcname, usagehint)
            usagestr = '';
            if ~exist('funcname','var')
                return;
            end
            if ~exist('usagename','var')
                usagehint='';
            end
            idx = obj.GetIdx(funcname);
            if isempty(idx)
                return;
            end            
            usagestr = obj.entries(idx).GetUsageStrDecorated(usagehint);
        end

    end
end
