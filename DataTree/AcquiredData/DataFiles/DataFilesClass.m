classdef DataFilesClass < handle
    
    properties
        files;
        type;
        err;
        errmsg;
        pathnm;
        config;
        nfiles;
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = DataFilesClass(varargin)
            obj.type = '';
            obj.pathnm = pwd;
            obj.nfiles = 0;
            obj.err = -1;
            obj.errmsg = {};
            
            skipconfigfile = false;
            askToFixNameConflicts = [];
            
            if nargin==0
                return
            end            
            if nargin==1
                obj.pathnm = varargin{1};
            end            
            if nargin==2
                obj.pathnm = varargin{1};
                obj.type = varargin{2};
            end            
            if nargin==3
                obj.pathnm = varargin{1};
                obj.type = varargin{2};
                if strcmp(varargin{3}, 'standalone')
                    skipconfigfile = true;
                end
            end            
            if nargin==4
                obj.pathnm = varargin{1};
                obj.type = varargin{2};
                if strcmp(varargin{3}, 'standalone')
                    skipconfigfile = true;
                end
                askToFixNameConflicts = varargin{4};
            end
                        
            if obj.type(1)=='.'
                obj.type(1)='';
            end
            obj.pathnm = filesepStandard(obj.pathnm,'full');
            
            % Configuration parameters
            obj.config = struct('RegressionTestActive','','AskToFixNameConflicts',1);
            cfg = ConfigFileClass();
            if skipconfigfile==false
                str = cfg.GetValue('Regression Test Active');
                if strcmp(str,'true')
                    obj.config.RegressionTestActive=true;
                else
                    obj.config.RegressionTestActive=false;
                end
            else
                obj.config.RegressionTestActive=false;
            end
            if ~isempty(askToFixNameConflicts)
                obj.config.AskToFixNameConflicts = askToFixNameConflicts;
            elseif strcmp(cfg.GetValue('Fix File Name Conflicts'), sprintf('don''t ask again'))
                obj.config.AskToFixNameConflicts = 0;
            end
            
            if nargin==0
                return;
            end
            
            obj.err = 0;
            obj.files = mydir(obj.pathnm);
            GetDataSet(obj);
        end
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj)
            if exist(obj.pathnm, 'dir')~=7
                error('Invalid subject folder: ''%s''', obj.pathnm);
            end
            obj.findDataSet(obj.type);
            obj.ErrorCheckName();
        end

        
        % ----------------------------------------------------
        function findDataSet(obj, type)
            obj.files = mydir([obj.pathnm, '/*.', type]);
            if isempty( obj.files )                
                % If there are no data files in current dir, don't give up yet - check
                % the subdirs for data files.
                dirs = mydir(obj.pathnm);
                for ii = 1:length(dirs)
                    if dirs(ii).isdir && ...
                            ~strcmp(dirs(ii).name,'.') && ...
                            ~strcmp(dirs(ii).name,'..') && ...
                            ~strcmp(dirs(ii).name,'hide')
                        dirs(ii).idx = length(obj.files)+1;
                        foos = mydir([obj.pathnm, dirs(ii).name, '/*.', type]);
                        nfoos = length(foos);
                        if nfoos>0
                            for jj = 1:nfoos
                                foos(jj).subjdir      = dirs(ii).name;
                                foos(jj).subjdiridx   = dirs(ii).idx;
                                foos(jj).idx          = dirs(ii).idx+jj;
                                foos(jj).filename     = foos(jj).name;
                                foos(jj).name         = [dirs(ii).name, '/', foos(jj).name];
                                foos(jj).map2group    = struct('iGroup',0, 'iSubj',0, 'iRun',0);
                                foos(jj).pathfull     = dirs(ii).pathfull;
                                if ~foos(jj).isdir
                                    obj.nfiles = obj.nfiles+1;
                                end
                            end
                            
                            % Add file from current subdir to files struct
                            if isempty(obj.files)
                                obj.files = dirs(ii);
                            else
                                obj.files(end+1) = dirs(ii);
                            end
                            obj.files(end+1:end+nfoos) = foos;                                                        
                        end
                    end
                end
            else
                for ii = 1:length(obj.files)
                    obj.files(ii).pathfull = obj.pathnm;
                end
                obj.nfiles = obj.nfiles+length(obj.files);
            end
        end
        
        
        
        % ----------------------------------------------------
        function getDataFile(obj, filename)
            obj.files = mydir(filename);
        end
        
        
        
        % ----------------------------------------------------
        function ErrorCheckName(obj)
            for ii = length(obj.files):-1:1
                if obj.files(ii).ErrorCheckName()<0
                    q = obj.AskToFixNameConflicts(ii);                    
                    if q == 1
                        obj.files(ii).FixNameConflict();
                    else
                        obj.files(ii).NameConflictFixed();
                    end
                end
                if obj.files(ii).GetError()<0
                    obj.err = -1;
                end
            end
        end
        
        
        
        % --------------------------------------------------------------------------
        function answer = AskToFixNameConflicts(obj, ii)
            answer = 0;
            if obj.config.AskToFixNameConflicts == 0
                obj.files(ii).NameConflictFixed();
                return
            end
            q = MenuBox(obj.GetErrorMsg(ii), {'YES','NO'},[],[],'askEveryTimeOptions');
            if q(1) == 0
                return;
            end
            if length(q)>1 && q(2) == 1
                cfg = ConfigFileClass();
                cfg.SetValue('Fix File Name Conflicts', sprintf('don''t ask again'));
                cfg.Save()
                obj.config.AskToFixNameConflicts = 0;
            end
            if q(1)==2
                obj.files(ii).NameConflictFixed();
            end
            answer = q(1);
        end
        
        
        
        % -----------------------------------------------------
        function errmsg = GetErrorMsg(obj, ii)
            p1      = fileparts(obj.files(ii).GetName());
            [p2,f2] = fileparts(filesepStandard(obj.files(ii).pathfull,'nameonly:file'));
            [~,f3]  = fileparts(p2);
            if isfile_private(obj.files(ii).GetName())
                filetype = 'file';
            else
                filetype = 'folder';
            end
            containingFolder = '';
            if obj.files(ii).GetError() == -1
                containingFolder = p1;
            end
            if obj.files(ii).GetError() == -2
                containingFolder = f2;
            end
            if obj.files(ii).GetError() == -3
                containingFolder = f3;
            end
            msg{1} = sprintf('WARNING: The current %s (%s) has the same name as the folder (%s) containing it. ', filetype, obj.files(ii).GetName(), containingFolder);
            msg{2} = sprintf('All %ss should have a different name than the folder containing them, otherwise ', ['F',filetype(2:end)]);
            msg{3} = sprintf('it may cause incorrect results in processing. Do you want to rename this %s?', filetype);
            errmsg = [msg{:}];            
        end
        

        
        % -------------------------------------------------------
        function pushbuttonLoadDataset_Callback(~, hObject)
            hp = get(hObject,'parent');
            hc = get(hp,'children');
            for ii=1:length(hc)
                
                if strcmp(get(hc(ii),'tag'),'pushbuttonLoad')
                    hButtnLoad = hc(ii);
                elseif strcmp(get(hc(ii),'tag'),'pushbuttonSelectAnother')
                    hButtnSelectAnother = hc(ii);
                end
                
            end
            
            if hObject==hButtnLoad
                delete(hButtnSelectAnother);
            elseif hObject==hButtnSelectAnother
                delete(hButtnLoad);
            end
            delete(hp);
        end
            
        
        % ----------------------------------------------------------
        function b = isempty(obj)
            if isempty(obj.files)
                b = true;
            else
                b = false;
            end
        end
       
        
                
        % ----------------------------------------------------------
        function found = ConvertedFrom(obj, src)
            found = zeros(length(src.files), 1);
            for ii = 1:length(src.files)
                if src.files(ii).isdir
                    found(ii) = -1;
                    continue;
                end
                [ps, fs] = fileparts(src.files(ii).name);
                for jj = 1:length(obj.files)
                    [pd, fd] = fileparts(obj.files(jj).name);
                    if strcmp(filesepStandard([ps,'/',fs], 'nameonly'), filesepStandard([pd,'/',fd], 'nameonly'))
                        found(ii) = 1;
                        break;
                    else
                        dbgpt = 1;
                    end
                end
            end
        end
        
        
        
        % ----------------------------------------------------------
        function err = GetError(obj)
            err = obj.err;
        end
        
    end
end
