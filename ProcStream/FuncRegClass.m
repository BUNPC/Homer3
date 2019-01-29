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
        function idx = FindEntry(obj, funcname)
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
        
    end
    
end
