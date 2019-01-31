classdef FuncRegClass < matlab.mixin.Copyable

    properties
        userfuncdir
        userfuncfiles       
        entriesGroup
        entriesSubj
        entriesRun
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegClass()
            obj.entriesGroup = FuncRegEntryClass().empty();
            obj.entriesSubj = FuncRegEntryClass().empty();
            obj.entriesRun = FuncRegEntryClass().empty();
            obj.userfuncdir = obj.FindUserFuncDir();
            obj.userfuncfiles = [];
            obj.Load();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Load(obj)
            filesG = dir([obj.userfuncdir, 'hmrG_*.m']);
            filesS = dir([obj.userfuncdir, 'hmrS_*.m']);
            filesR = dir([obj.userfuncdir, 'hmrR_*.m']);
           
            for ii=1:length(filesG)
                obj.entriesGroup(ii) = FuncRegEntryClass(filesG(ii).name);
            end
            for ii=1:length(filesS)
                obj.entriesSubj(ii) = FuncRegEntryClass(filesS(ii).name);
            end
            for ii=1:length(filesR)
                obj.entriesRun(ii) = FuncRegEntryClass(filesR(ii).name);
            end
            files = [filesG; filesS; filesR];
            for kk=1:length(files)
                obj.userfuncfiles{kk} = [obj.userfuncdir, files(kk).name];
            end
        end
        
               
        % ----------------------------------------------------------------------------------
        function [usagestr, idx] = FindUsageGroup(obj, funcname, usagehint)
            if ~exist('funcname','var')
                return;
            end
            if ~exist('usagename','var')
                usagehint='';
            end
            usagestr = '';
            idx = 0;
            for ii=1:length(obj.entriesGroup)
                if strcmp(obj.entriesGroup(ii).GetName(), funcname)
                    tempstr = obj.entriesGroup(ii).GetUsageStr(usagehint);
                    if isempty(tempstr)
                        return;
                    end
                    usagestr = sprintf('@ %s\\n', strinsert(tempstr, '%','%'));
                    idx = ii;
                    break;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function [usagestr, idx] = FindUsageSubj(obj, funcname, usagehint)
            if ~exist('funcname','var')
                return;
            end
            if ~exist('usagename','var')
                usagehint='';
            end
            usagestr = '';
            idx = 0;
            for ii=1:length(obj.entriesSubj)
                if strcmp(obj.entriesSubj(ii).GetName(), funcname)
                    tempstr = obj.entriesSubj(ii).GetUsageStr(usagehint);
                    if isempty(tempstr)
                        return;
                    end
                    usagestr = sprintf('@ %s\\n', strinsert(tempstr, '%','%'));
                    idx = ii;
                    break;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function [usagestr, idx] = FindUsageRun(obj, funcname, usagehint)
            if ~exist('funcname','var')
                return;
            end
            if ~exist('usagename','var')
                usagehint='';
            end
            usagestr = '';
            idx = 0;
            for ii=1:length(obj.entriesRun)
                if strcmp(obj.entriesRun(ii).GetName(), funcname)
                    tempstr = obj.entriesRun(ii).GetUsageStr(usagehint);
                    if isempty(tempstr)
                        return;
                    end
                    usagestr = sprintf('@ %s\\n', strinsert(tempstr, '%','%'));
                    idx = ii;
                    break;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function AddEntry(obj)
        end
        
        
        % ----------------------------------------------------------------------------------
        function EditEntry(obj, idx)
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteEntry(obj, idx)
        end

        
        % ----------------------------------------------------------------------------------
        function userfuncdir = FindUserFuncDir(obj)
            userfuncdir = '';
            if isdeployed()
                if ispc
                    userfuncdir = 'c:/users/public/homer3/userfunctions/';
                elseif ismac()
                    userfuncdir = '~/homer3/userfunctions/';                    
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
        function usagestrs = GetUsageStrsGroup(obj, addnewline)
            if ~exist('addnewline','var')
                addnewline = 0;
            end
            if addnewline
                nl = newline();
            else
                nl = '';
            end
            usagestrs = cell(2*length(obj.entriesGroup), 1);
            kk = 1;
            for ii=1:length(obj.entriesGroup)
                for jj=1:obj.entriesGroup(ii).GetOptionsNum()
                    usagestrs{kk} = sprintf('@ %s%s', obj.entriesGroup(ii).GetUsageStr(jj), nl);
                    kk=kk+1;
                end
            end
            % Remove extra empty cells 
            usagestrs = usagestrs(~cellfun('isempty',usagestrs));
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagestrs = GetUsageStrsSubj(obj, addnewline)
            if ~exist('addnewline','var')
                addnewline = 0;
            end
            if addnewline
                nl = newline();
            else
                nl = '';
            end
            usagestrs = cell(2*length(obj.entriesSubj), 1);
            kk = 1;
            for ii=1:length(obj.entriesSubj)
                for jj=1:obj.entriesSubj(ii).GetOptionsNum()
                    usagestrs{kk} = sprintf('@ %s%s', obj.entriesSubj(ii).GetUsageStr(jj), nl);
                    kk=kk+1;
                end
            end
            % Remove extra empty cells 
            usagestrs = usagestrs(~cellfun('isempty',usagestrs));
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagestrs = GetUsageStrsRun(obj, addnewline)
            if ~exist('addnewline','var')
                addnewline = 0;
            end
            if addnewline
                nl = newline();
            else
                nl = '';
            end
            usagestrs = cell(2*length(obj.entriesRun), 1);
            kk = 1;
            for ii=1:length(obj.entriesRun)
                for jj=1:obj.entriesRun(ii).GetOptionsNum()
                    usagestrs{kk} = sprintf('@ %s%s', obj.entriesRun(ii).GetUsageStr(jj), nl);
                    kk=kk+1;
                end
            end
            % Remove extra empty cells 
            usagestrs = usagestrs(~cellfun('isempty',usagestrs));
        end
    
        
        % ----------------------------------------------------------------------------------
        function usagestrs = GetUsageStrsAll(obj, addnewline)
            if ~exist('addnewline','var')
                addnewline = 0;
            end
            usagestrs_g = GetUsageStrsGroup(obj, addnewline);
            usagestrs_s = GetUsageStrsSubj(obj, addnewline);
            usagestrs_r = GetUsageStrsRun(obj, addnewline);
            usagestrs = [usagestrs_g; usagestrs_s; usagestrs_r];            
        end
        
        
        

        
        
    end
    
    
end
