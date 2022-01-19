classdef FileClass < matlab.mixin.Copyable

    
    properties
        % Same properties as the fields in the file struct returned 
        % by matlab's dir function
        name
        fid
        date
        bytes
        isdir
        datenum

        % FileClass specific properties
        namePrev
        idx
        subjdir
        subjdiridx
        filename
        map2group
        pathfull
        err
        logger
    end
    
    methods

        function obj = FileClass(varargin)
            global logger
            
            obj.name       = '';
            obj.date       = '';
            obj.bytes      = 0;
            obj.isdir      = 0;
            obj.datenum    = 0;
            
            obj.namePrev   = '';
            obj.idx        = 0;
            obj.subjdir    = '';
            obj.subjdiridx = 0;
            obj.filename   = '';
            obj.map2group  = struct('iSubj',0,'iRun',0);
            obj.pathfull   = '';
            obj.err        = -1;          % Assume file is not loadable
            obj.logger     = InitLogger(logger);            
            
            if nargin==0
                return;
            end
            if isstruct(varargin{1})
                file_struct = varargin{1};
            elseif ischar(varargin{1})
                file_struct = obj.Dirname2Struct(varargin{1});
            else
                return;
            end
            if strcmp(file_struct.name,'.')
                return;
            end
            if strcmp(file_struct.name,'..')
                return;
            end
            
            % Copy all fields of file_struct that exist in this class to this object. 
            fields = propnames(file_struct);
            for ii=1:length(fields)
                if isproperty(obj, fields{ii})
                    eval( sprintf('obj.%s = file_struct.%s;', fields{ii}, fields{ii}) );
                end
            end

            % Now assign all the properies specific to this class
            obj.idx = 0;
            obj.subjdir = '';
            obj.subjdiridx = 0;
            obj.filename = obj.name;
            obj.map2group = struct('iSubj',0,'iRun',0);
            obj.err        = 0;          % Assume file is not loadable
        end


        % ----------------------------------------------------------
        function MapFile2Group(obj, iGroup, iSubj, iRun)
            obj.map2group.iGroup = iGroup;
            obj.map2group.iSubj = iSubj;
            if ~obj.isdir
                obj.map2group.iRun  = iRun;
            else
                obj.map2group.iRun  = 0;
            end
        end
        
        
        % -----------------------------------------------------------
        function file_struct = Dirname2Struct(~, dirnameFull)
            file_struct = [];
            [~, dirname] = fileparts(dirnameFull);
            dirs = dir([dirnameFull, '/..']);
            for ii=1:length(dirs)
                if strcmpi(dirname, dirs(ii).name)
                    file_struct = dirs(ii);
                    break;
                end
            end
        end
        
        
        
        % -----------------------------------------------------------
        function b = Exist(obj, filename)
            % As of version R2016a, Matlab's exist function is not a reliable way to check if a 
            % pathname is the name of an exiting file. For example, exist will report a file as 
            % exiting even if it doesn't, but the file name with an extension does exit. So let's 
            % say a file with the name <filename> does not exist but <filename>.cfg does. 
            % exist(<filename>) will return 2 even though <filename> does not actually exist. This 
            % is a problem which is fixed by this method.
            % 
            if nargin==2
                fname = filename;
            else
                fname = obj.filename;
            end
            b = ~isempty(dir(fname));
        end
        
        
        % -----------------------------------------------------------
        function [groupName, subjName, runName] = ExtractNames(obj)
            if obj.pathfull(end)=='/' || obj.pathfull(end)=='\'
               groupPath = obj.pathfull(1:end-1);
            else
               groupPath = obj.pathfull;
            end
            [~, groupName] = fileparts(groupPath);
            subjName = '';
            runName = '';

            %%%% obj is a group folder
            if obj.isdir && strcmp(groupName, obj.name)
                return;
            end
            
            %%%% obj is a subject folder
            if obj.isdir
                subjName = obj.name;
                return;
            end

            %%%% obj is a data file representing single run
            %             [~, fname, ext] = fileparts(obj.name);
            %             runName = [fname, ext];
            runName = obj.name;
            
            % Determine subject name from filename
            [pname, fname] = fileparts(obj.name);
            if ~isempty(pname)
                subjName = pname;
            else
                k1=strfind(fname,'_run');
                if(~isempty(k1))
                    % Subject name is part of the file name
                    subjName = fname(1:k1-1);
                else
                    % Subject name is the file name minus extension
                    subjName = fname;
                end
            end
        end
        
        
        % -----------------------------------------------------------
        function p = GetFilesPath(obj)
            p = obj.pathfull;            
        end
                
        
        % -----------------------------------------------------------
        function b = Loadable(obj)
            if obj.err==0
                b = true;
            else
                b = false;
            end
        end

        
        % -----------------------------------------------------------
        function Loaded(obj)
            obj.err = 0;
        end
        
        
        % -----------------------------------------------------------
        function b = IsFile(obj)
            if obj.isdir
                b = false;
            else
                b = true;
            end
        end
        
        
        % -----------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.name)
                return;
            end
            if obj.err ~= 0
                return;
            end
            b = false;            
        end

        
        % ----------------------------------------------------
        function err = ErrorCheckName(obj)
            a = obj.name;
            [p1,f1] = fileparts(obj.name);
            [p2,f2] = fileparts(filesepStandard(obj.pathfull,'nameonly:file'));
            [~,f3]  = fileparts(p2);
            if strcmp(f1, p1)
                obj.err = -1;
            end
            if strcmp(f1, f2)
                obj.err = -2;
            end
            if strcmp(f1, f3)
                obj.err = -3;
            end
            err = obj.err;
        end
        
        
                
        % ----------------------------------------------------
        function FixNameConflict(obj)
            if obj.err == 0
                return
            end
            keeptrying = true;
            while keeptrying
                [p,f,e] = fileparts(obj.name);
                suggestedRenaming = obj.SuggestRenaming(f,e);
                [rootpath, newname] = SaveFileGUI(suggestedRenaming, p, '', 'rename');
                newnameFull = [rootpath, newname];
                if isempty(newnameFull)
                    % Means user chnaged mind and canceled. So we call it fixed
                    obj.NameConflictFixed()
                    return;
                end
                if strcmp(newname, [f,e])
                    q = MenuBox('ERROR: The file name has not been renamed. Do you want to try again?', {'YES','NO'});
                    if q==1
                        continue;
                    else
                        return;
                    end
                end
                if pathscompare(obj.name, newnameFull)
                    return;
                end
                if ~isempty(e)
                    d = dir([filesepStandard(p),f,'.*']);
                    [p2,f2] = fileparts(newnameFull);
                    for ii = 1:length(d)
                        [~,~,e1] = fileparts(d(ii).name);
                        obj.logger.Write(sprintf('FileClass: Renaming  %s to %s\n', [filesepStandard(p),f,e1], [filesepStandard(p2),f2,e1]));
                        movefile([filesepStandard(p),f,e1], [filesepStandard(p2),f2,e1]);
                    end
                else
                    obj.logger.Write(sprintf('FileClass: Renaming  %s to %s\n', obj.name, newnameFull));
                    movefile(obj.name, newnameFull);
                end
                obj.namePrev = obj.name;
                obj.name = [filesepStandard(p), newname];
                keeptrying = false;
            end
        end
        
        
        
        % -----------------------------------------------------------------
        function name = SuggestRenaming(~, fname, ext)
            n = 1;
            base = fname;
            if isempty(ext)
                addon = 's';
            else
                addon = 'r';
            end
            name = sprintf('%s_%s%d%s', base, addon, n, ext);
            while ispathvalid(name)
                n = n+1;
                name = sprintf('%s_%s%d%s', base, addon, n, ext);
            end
        end
        
        
        % -----------------------------------------------------
        function NameConflictFixed(obj)
            obj.err = 0;
        end
        
        
        % -----------------------------------------------------
        function name = GetName(obj)
            name = obj.name;
        end
        
        
        % -----------------------------------------------------
        function err = GetError(obj)
            err = obj.err;
        end
        
        
    end
       
end