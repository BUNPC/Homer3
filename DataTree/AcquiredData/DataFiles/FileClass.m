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
        filename
        map2group
        rootdir
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
            obj.filename   = '';
            obj.map2group  = struct('iGroup',0, 'iSubj',0, 'iSess',0, 'iRun',0);
            obj.rootdir    = '';
            obj.err        = -1;          % Assume file is not loadable
            obj.logger     = InitLogger(logger);            
            
            if nargin==0
                return;
            end
            
            if nargin > 0
                if isstruct(varargin{1})
                    file = varargin{1};
                elseif ischar(varargin{1})
                    file = obj.Dirname2Struct(varargin{1});
                else
                    return;
                end
            end
            
            if nargin > 1
                file.rootdir = varargin{2};
            else
                file.rootdir = pwd;
            end
            file.rootdir = filesepStandard(file.rootdir);            
            
            obj.Add(file);
        end


        % ----------------------------------------------------------
        function Add(obj, obj2)
            if strcmp(obj2.name, '.')
                return
            end
            if strcmp(obj2.name, '..')
                return
            end
            
            if isproperty(obj2, 'folder')
                rootdir = [filesepStandard(obj2.folder), obj2.name]; %#ok<*PROPLC>
            else
                rootdir = [filesepStandard(obj2.rootdir), obj2.name];                
            end
            
            obj.idx          = obj.idx+1;
            obj.isdir        = obj2.isdir;
            obj.filename     = obj2.name;
            obj.name         = getPathRelative(rootdir, obj2.rootdir);
            obj.rootdir 	 = obj2.rootdir;
            obj.err          = 0;          % Set error to NO ERROR            
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
        function file = Dirname2Struct(~, dirname)
            file = [];
            if ~ispathvalid(dirname)
                return
            end
            if ispathvalid(dirname, 'dir') && ~includes(dirname, '*')
                if dirname(end)=='/' || dirname(end)=='\'
                    k = length(dirname);
                else
                    k = length(dirname)+1;
                end
                dirname(k) = '*';
            end
            file = dir(dirname);
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
        function  [parts, fname] = GetPathParts(obj)
            parts = str2cell_fast(obj.name, '/');
            if isempty(parts)
                return;
            end
            
            % Drop extension off last file part
            [~,fname] = fileparts(parts{end});
            parts{end} = fname;
            
            if length(parts)<2
                return;
            end
            
            % Consolidate second to last 'nirs' part with last part   
            if strcmp(parts{end-1}, 'nirs')
                parts{end} = [parts{end-1}, '/', parts{end}];
                parts(end-1) = [];
            end
        end
        
        
        
        % -----------------------------------------------------------
        function [groupName, subjName, sessName, runName] = ExtractNames(obj)
            groupName = obj.ExtractGroupName();
            subjName = '';
            sessName = '';
            runName = '';
            
            % NOTE: obj.name is the relative path from group folder to the
            % object file or folder. 
            [parts, fname] = obj.GetPathParts();
            subparts = str2cell_fast(fname,'_');

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Here are the 4 outputs [groupName, subjName, sessName, runName] of 
            % this functions for the 7 different acceptable group folder structures 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Folder Structure 1:   Flat #1
            %
            %     G1 
            %       R1.ext          ==>  [G1,  sub_R1,  ses_sub_R1,  R1]
            %       R2.ext          ==>  [G1,  sub_R2,  ses_sub_R2,  R2]
            %       R3.ext          ==>  [G1,  sub_R3,  ses_sub_R3,  R3]
            if obj.IsFile && length(parts)==1 && length(subparts)==1
                subjName = ['sub_', fname];
                sessName = ['ses_', subjName];
                runName  = obj.name;
            end

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Folder Structure 2:  Flat #2
            %
            %     G1 
            %       S1_R1.ext       ==>  [G1,  S1,  ses_S1_R1,  R1]
            %       S1_R2.ext       ==>  [G1,  S1,  ses_S1_R2,  R2]
            %       S1_R3.ext       ==>  [G1,  S1,  ses_S1_R3,  R3]
            %       S2_R1.ext       ==>  [G1,  S2,  ses_S2_R1,  R1]
            %       S2_R2.ext       ==>  [G1,  S2,  ses_S2_R2,  R2]
            %       S3_R3.ext       ==>  [G1,  S2,  ses_S2_R3,  R3]
            if obj.IsFile && length(parts)==1 && length(subparts)==2
                subjName = subparts{1};
                sessName = ['ses_', subjName, '_', fname];
                runName  = obj.name;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Folder Structure 3:  Flat #3
            %
            %     G1 
            %       S1_E1_R1.ext    ==>  [G1,  S1,  E1_S1,  R1]
            %       S1_E1_R2.ext    ==>  [G1,  S1,  E1_S1,  R2]
            %       S1_E1_R3.ext    ==>  [G1,  S1,  E1_S1,  R3]
            %       S2_E1_R1.ext    ==>  [G1,  S2,  E1_S2,  R1]
            %       S2_E1_R2.ext    ==>  [G1,  S2,  E1_S2,  R2]
            %       S2_E1_R3.ext    ==>  [G1,  S2,  E1_S2,  R3]
            %       S3_E1_R1.ext    ==>  [G1,  S3,  E1_S3,  R1]
            %       S3_E2_R2.ext    ==>  [G1,  S3,  E2_S3,  R2]
            %       S3_E2_R3.ext    ==>  [G1,  S3,  E2_S3,  R3]
            if obj.IsFile && length(parts)==1 && length(subparts)>2
                subjName = subparts{1};
                sessName = [subparts{2}, '_', subjName];
                runName  = obj.name;
            end
             
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Folder Structure 4:  Subject
            %
            %     G1 
            %       S1
            %         R1.ext       ==>  [G1,  S1,  R1_E,  R1]
            %         R2.ext       ==>  [G1,  S1,  R2_E,  R2]
            %         R3.ext       ==>  [G1,  S1,  R3_E,  R3]
            %
            %
            %            OR
            %
            %
            %  Folder Structure 5:  BIDS #1
            %
            %     G1 
            %       S1 
            %         nirs/R1.ext    ==>  [G1,  S1,  E1,  R1]
            %         nirs/R2.ext    ==>  [G1,  S1,  E1,  R2]
            %         nirs/R3.ext    ==>  [G1,  S1,  E1,  R3]           
            if obj.IsDir && length(parts)==1
                subjName = obj.name;
            elseif obj.IsFile && length(parts)==2
                subjName = parts{1};
                sessName = [subjName, '/ses-', fname];
                runName  = obj.name;
            end
            
                        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %  Folder Structure 6:  BIDS-like
            %
            %     G1 
            %       S1 
            %         E1 
            %           R1.ext    ==>  [G1,  S1,  E1,  R1]
            %           R2.ext    ==>  [G1,  S1,  E1,  R2]
            %           R3.ext    ==>  [G1,  S1,  E1,  R3]
            %
            %
            %            OR
            %
            %
            %  Folder Structure 7:  BIDS #2
            %
            %     G1 
            %       S1 
            %         E1 
            %           nirs/R1.ext    ==>  [G1,  S1,  E1,  R1]
            %           nirs/R2.ext    ==>  [G1,  S1,  E1,  R2]
            %           nirs/R3.ext    ==>  [G1,  S1,  E1,  R3]
            if obj.IsDir && length(parts)==1
                subjName = obj.name;
            elseif obj.IsDir && length(parts)==2
                subjName = parts{1};
                sessName = [subjName, '/', obj.name];
            elseif obj.IsFile && length(parts)==3
                subjName = parts{1};
                sessName = [subjName, '/', parts{2}];
                runName  = obj.name;
            end
            
        end
            
            
        % -----------------------------------------------------------
        function groupName = ExtractGroupName(obj)            
            if obj.rootdir(end)=='/' || obj.rootdir(end)=='\'
               groupPath = obj.rootdir(1:end-1);
            else
               groupPath = obj.rootdir;
            end
            [~, groupName, ext] = fileparts(groupPath);
            groupName = [groupName, ext];
        end
        
        
        % -----------------------------------------------------------
        function subjName = ExtractSubjName(obj)
            subjName = '';
            parts = str2cell_fast(obj.name, '/');
            [pname, fname] = fileparts(obj.name);
            
            if obj.isdir
                
                if length(parts) == 1
                    subjName = obj.name;
                end
                
            else
                
                % Determine subject name from filename
                if ~isempty(pname)
                    subjName = pname;
                else
                    c = str2cell_fast(fname,'_');
                    for ii = 1:length(c)
                        if includes(c{ii}, 'ses-')
                            break;
                        end
                        if includes(c{ii}, '_run')
                            break;
                        end
                        subjName = sprintf('%s_%s', subjName, c{ii});
                    end
                end
                
            end
        end
        
        
        % -----------------------------------------------------------
        function sessName = ExtractSessName(obj)
            sessName = '';
            parts = str2cell_fast(obj.name, '/');
            
            if obj.isdir
                
                if length(parts) == 2
                    sessName = obj.name;
                end
                
            else
                
                % Determine subject name from filename
                if length(parts) == 4
                    sessName = parts{2};
                else
                    c = str2cell_fast(fname,'_');
                    for ii = 1:length(c)
                        if includes(c{ii}, 'ses-')
                            sessName = c{ii};
                            break;
                        end
                    end
                end
                
            end
        end
        
        
        
        % -----------------------------------------------------------
        function p = GetFilesPath(obj)
            p = obj.rootdir;            
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
        function b = IsDir(obj)
            if obj.isdir
                b = true;
            else
                b = false;
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
            [p1,f1] = fileparts(obj.name);
            [p2,f2] = fileparts(filesepStandard(obj.rootdir,'nameonly:file'));
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