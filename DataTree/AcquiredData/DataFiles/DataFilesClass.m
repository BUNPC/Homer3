classdef DataFilesClass < handle
    
    properties
        files;
        filesErr;
        filetype;
        dirFormats;
        err;
        errmsg;
        rootdir;
        config;
        nfiles;
        logger
    end
    
    properties (Access = private)
        lookupTable
        excludedFolders
        savedFilename
        changed
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = DataFilesClass(varargin)
            obj.files = FileClass.empty();
            obj.filesErr = FileClass.empty();
            obj.filetype = '';
            obj.rootdir = pwd;
            obj.nfiles = 0;
            obj.err = -1;
            obj.errmsg = {};
            obj.dirFormats = struct('type',0, 'choices',{{}});
            obj.lookupTable = [];
            obj.changed = false;

            global logger
            global cfg
            
            logger = InitLogger(logger);
            cfg    = InitConfig(cfg);
            
            obj.logger = logger;
            obj.excludedFolders = {};
            
            skipconfigfile = false;
            askToFixNameConflicts = [];
            
            if nargin==0
                return
            end            
            if nargin==1
                obj.rootdir = varargin{1};
            end            
            if nargin==2
                obj.rootdir = varargin{1};
                obj.filetype = varargin{2};
            end
            if nargin==3
                obj.rootdir = varargin{1};
                obj.filetype = varargin{2};
                if strcmp(varargin{3}, 'standalone')
                    skipconfigfile = true;
                end
            end            
            if nargin==4
                obj.rootdir = varargin{1};
                obj.filetype = varargin{2};
                if strcmp(varargin{3}, 'standalone')
                    skipconfigfile = true;
                end
                askToFixNameConflicts = varargin{4};
            end
                        
            if obj.filetype(1) == '.'
                obj.filetype(1) = '';
            end
            obj.rootdir = filesepStandard(obj.rootdir,'full');           
            
            % Configuration parameters
            obj.config = struct('RegressionTestActive','',  'AskToFixNameConflicts',1, 'DerivedDataDir','', 'DerivedDataRootDir','');
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
            obj.config.SuppressErrorChecking = false;
            if ~isempty(askToFixNameConflicts)
                obj.config.AskToFixNameConflicts = askToFixNameConflicts;
            elseif strcmp(cfg.GetValue('Fix File Name Conflicts'), sprintf('don''t ask again'))
                obj.config.AskToFixNameConflicts = 0;
            end
            
            if ~obj.config.AskToFixNameConflicts
                obj.config.SuppressErrorChecking = true;                
            end
            
            [p, f] = fileparts(cfg.GetValue('Output Folder Name'));
            if isempty(p)
                obj.config.DerivedDataDir = f;
            else
                obj.config.DerivedDataDir = p;
            end
            obj.excludedFolders = {...
                [obj.rootdir, obj.config.DerivedDataDir];
                [obj.rootdir, 'fw'];
                [obj.rootdir, 'imagerecon'];
                [obj.rootdir, 'anatomical'];
                };
            obj.config.DerivedDataRootDir = [obj.rootdir, obj.config.DerivedDataDir, '/', f, '/'];
            obj.savedFilename = [obj.config.DerivedDataRootDir, 'DatasetFiles', '_', obj.filetype, '.mat'];
            if nargin==0
                return;
            end
            
            obj.err = 0;
            obj.InitFolderFormats();
            obj.GetDataSet();
            obj.SaveDataSet();
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function Compare(obj)
            if obj.IsEmpty()
                return
            end
            obj2 = DataFilesClass();
            obj2.filetype = obj.filetype;
            obj2.dirFormats = obj.dirFormats;
            obj2.GetDataSet('skipsaveddata')
            
            % BUG fix:  rootdir must be same for both objects. But the saved object could have
            obj.rootdir = obj2.rootdir;
            
            %%%% Create list of all the saved names for sorting later
            filesSaved = cell(length(obj.files),1);
            filesSavedErr = cell(length(obj.filesErr),1);
            for ii = 1:length(obj.files)
                filesSaved{ii} = obj.files(ii).name;
            end
            for ii = 1:length(obj.filesErr)
                filesSavedErr{ii} = obj.filesErr(ii).name;
            end

            %%%% Move any files from saved error list that have been updated to nonerror list 
            N = length(obj.filesErr);
            for ii = N:-1:1
                for jj = 1:length(obj2.files)
                    if strcmp(obj.filesErr(ii).name, obj2.files(jj).name)
                        if obj.filesErr(ii).datenum ~= obj2.files(jj).datenum
                            obj.filesErr(ii) = [];
                            filesSavedErr{ii} = [];
                            obj.files(end+1) = obj2.files(jj);
                            if ~obj2.files(jj).isdir
                                obj.nfiles = obj.nfiles+1;
                            end
                            filesSaved{end+1} = obj2.files(jj).name;        %#ok<AGROW>
                            obj.logger.Write('%d. Mismatch in dates for saved data in %s. Will re-validate this file.\n', jj, obj.filesErr(ii).name);
                            obj.changed = true;                            
                        end
                        break
                    end
                end
            end
            
                        
            %%%% Now check saved object nonerror list
            N = length(obj.files);
            for ii = N:-1:1
	            found = false;            
                for jj = 1:length(obj2.files)
                    if strcmp(obj.files(ii).name, obj2.files(jj).name)
                        found = true;
                        if obj.files(ii).datenum ~= obj2.files(jj).datenum
                            obj.files(ii) = obj2.files(jj).copy();
                            obj.logger.Write('%d. Mismatch in dates for saved data in %s. Will re-validate this file.\n', jj, obj.files(ii).name);
                            obj.changed = true;
                        end
                        break
                    end
                end
                if ~found
                    obj.logger.Write('%d. Deleting file %s from saved data.\n', ii, obj.files(ii).name);
                    if ~obj.files(ii).isdir
                        obj.nfiles = obj.nfiles-1;
                    end
                    obj.files(ii) = [];
                    filesSaved(ii) = [];                    
                    obj.changed = true;
                end     
            end
            
            % We don't need to check if files were added if there's no
            % change and the number of current files found is same as saved
            % number of files. Exist early. 
            if obj.changed == false
                if (length(obj.files) + length(obj.filesErr)) == length(obj2.files)
                    return
                end
            end
            
            
            %%%% Find which files were added to current dataset and add
            %%%% them to saved object
            for ii = 1:length(obj2.files)
                found = false;
                for jj = 1:length(obj.files)
                    if strcmp(obj2.files(ii).name, obj.files(jj).name)
                        found = true;
                        break
                    end
                end
                
                % If the current file filesCurr(ii) is not found in saved dataset then it's a new file. 
                % Add new file from current dataset to saved dataset
                if ~found
                    obj.files(end+1) = obj2.files(ii);
                    if ~obj2.files(ii).isdir
                        obj.nfiles = obj.nfiles+1;
                    end
                    filesSaved{end+1} = obj2.files(ii).name; %#ok<AGROW>
                    obj.logger.Write('%d. Adding new file %s to saved data.\n', jj, obj2.files(ii).name);
                    obj.changed = true;
                end
            end

            
            % Sort non-error files
            if obj.changed
                [~, order] = sort(filesSaved);
                obj.files = obj.files(order);
                obj.logger.Write('\n');
            end
            
        end
        

 
        % -----------------------------------------------------------------------------------
        function SaveDataSet(obj)
            if ~obj.changed
                return
            end
            obj.changed = false;
            obj.logger.Write('Saving DataFilesClass object in %s\n', obj.savedFilename);
            if ~exist(obj.config.DerivedDataRootDir, 'dir')
                mkdir(obj.config.DerivedDataRootDir)
            end
            save(obj.savedFilename, '-mat', 'obj');
        end
        

 
        % -----------------------------------------------------------------------------------
        function b = LoadDataSet(obj)
            b = false;
            if ~exist(obj.savedFilename, 'file')
                return
            end
            dataset = load(obj.savedFilename);
            dataset.obj.Compare();
            if isempty(dataset.obj.files) && isempty(dataset.obj.filesErr)
                return
            end
            obj.logger.Write('Loaded saved DataFilesClass object:    %s\n', obj.savedFilename);
            obj.Copy(dataset.obj);

            obj.ErrorCheck()
            obj.ErrorCheckName()
            b = true;
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj, skipsaveddata)
            if ~exist('skipsaveddata','var')
                skipsaveddata = '';
            end
            if ~strcmp(skipsaveddata, 'skipsaveddata')
                if obj.LoadDataSet()
                    return
                end
            end

            obj.changed = true;

            mode = '';            
            if obj.dirFormats.type == 0
                iFormats = 1:length(obj.dirFormats.choices);
            else
                iFormats = obj.dirFormats.type;
                mode = 'noerrorcheck';
            end
            if exist(obj.rootdir, 'dir')~=7
                error('Invalid subject folder: ''%s''', obj.rootdir);
            end
            for ii = iFormats
                obj.InitLookupTable();
                obj.FindDataSet(ii);
                
                if strcmp(mode,'noerrorcheck')
                    continue
                end
                if isempty(obj.files)
                    continue
                end                
                
                % Remove any files that cannot pass the basic test of loading
                % its data
                obj.ErrorCheck();
                if ~isempty(obj.files)
                    break
                end
                
                % If we're here it means we still have not found a valid dataset in any of the formats looked 
                % at so far, but obj.dirFormats.type may have been set to non-zero because a invalid dataset 
                % may have been found by obj.FindDataSet() then flagged as invalid by obj.ErrorCheck(). So make 
                % sure to reset format type here otherwise wrong format could be associated with saved dataset. 
                % To reproduce comment out this fix and add ONE error snirf file that does NOT belong in the 
                % dataset due to being in incompatible format folder structure. BUG FIX: Jay Dubb, May 8, 2024
                obj.dirFormats.type = 0;
            end
            if strcmp(mode,'noerrorcheck')
                return
            end
            obj.ErrorCheckFinal();
        end

        
        
        % -----------------------------------------------------------------------------------
        function InitFolderFormats(obj)
            obj.dirFormats.choices = {
                
                %%%% 1. Flat #1
                {
                    ['*_run*.', obj.filetype];
                }

                %%%% 2. Flat #2
                {
                    ['*.', obj.filetype];
                }
                
                %%%% 3. Subjects 
                {
                    '*';
                    ['*.', obj.filetype];
                }

                %%%% 4. BIDS #1,    sub-<label>[_ses-<label>][_task-<label>][_run-<index>]_nirs.snirf
                {                
                    'sub-*';
                    'ses-*';
                    ['nirs/sub-*_run-*_nirs.', obj.filetype];
                }
                                
                %%%% 5. BIDS #2 
                {
                    'sub-*';
                    ['nirs/sub-*_run-*_nirs.', obj.filetype];
                }
                
                %%%% 6. BIDS #3
                {
                    'sub-*';
                    ['nirs/sub-*_*_nirs.', obj.filetype];
                }
                
                %%%% 7. BIDS #4 
                {
                    '*';
                    ['nirs/sub-*_*_nirs.', obj.filetype];
                }
                
                %%%% 8. BIDS folder structure
                {
                    'sub-*';
                    'ses-*';
                    ['nirs/sub-*_run-*_nirs.', obj.filetype];
                }
                               
                %%%% 9. BIDS-like folder structure without file naming restrictions
                {
                    'sub-*';
                    'ses-*';
                    ['nirs/*.', obj.filetype];
                }
                                
                %%%% 10. BIDS-like folder structure without nirs sub-folder
                {
                    'sub-*';
                    'ses-*';
                    ['*.', obj.filetype];
                }
                
            };
        end
        

            
        
        % ----------------------------------------------------
        function FindDataSet(obj, iFormat, iPattern, parentdir)
            if ~exist('iFormat','var')
                iFormat = 1;
            end
            if ~exist('iPattern','var')
                iPattern = 1;
            end            
            if ~exist('parentdir','var')
                parentdir = obj.rootdir;
            end
            
            if iFormat > length(obj.dirFormats.choices)
                return
            end
            if iPattern > length(obj.dirFormats.choices{iFormat})
                return
            end
            parentdir = filesepStandard(parentdir);
            
            % Check if folder is excluded, if yes don't search there
            for ii = 1:length(obj.excludedFolders)
                if includes(parentdir, obj.excludedFolders{ii})
                    return;
                end
            end
            
            pattern = obj.dirFormats.choices{iFormat}{iPattern};
            
            dirs = mydir([parentdir, pattern], obj.rootdir);
            
            dirnamePrev = '';
            for ii = 1:length(dirs)
                if dirs(ii).IsEmpty()
                    continue;
                end
                if dirs(ii).IsFile()
                    % If the pattern that found this file has no extension
                    % that means this pattern is meant ONLY for folders. 
                    % Therefore any file matches should be skipped. 
                    % Bug Fix - JD, Jun 20, 2023
                    [~,~,ext] = fileparts(pattern);
                    if isempty(ext)  
                        continue
                    end
                    if includes(dirs(ii).name, obj.filetype)
                        if ~strcmp(dirs(ii).name, dirnamePrev)
                            obj.AddParentDirs(dirs(ii));
                        end
                        obj.AddFile(dirs(ii));
                    end
                    
                    if obj.dirFormats.type == 0 
                        obj.dirFormats.type = iFormat;
                    end
                elseif dirs(ii).IsDir()
                    obj.FindDataSet(iFormat, iPattern+1, [parentdir, dirs(ii).filename])
                end
                dirnamePrev = dirs(ii).name;
            end
        end
        

        
        % ----------------------------------------------------
        function AddParentDirs(obj, dirname)
            pathrel = getPathRelative([dirname.rootdir, dirname.name], obj.rootdir);
            subdirs = str2cell_fast(pathrel, {'/','\'});
            N = length(subdirs);
            for ii = 1:N-1
                if strcmp(subdirs{ii}, 'nirs')
                    continue;
                end
                pathrel2 = buildpathfrompathparts(subdirs(1:ii));
                if obj.SearchLookupTable(pathrel2)
                    continue;
                end
                obj.files(end+1) = FileClass([obj.rootdir, '/', pathrel2], obj.rootdir);
                obj.AddLookupTable(pathrel2)
            end
        end
        
        
        
        % ----------------------------------------------------
        function AddFile(obj, file)
            obj.files(end+1) = FileClass();
            obj.files(end).Add(file);
            obj.nfiles = obj.nfiles+1;
        end
        
        
        
        % ----------------------------------------------------
        function ErrorCheckName(obj)
            for ii = length(obj.files):-1:1
                if ~obj.files(ii).IsValidated()
                    continue;
                end
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
        
        
        
        % ----------------------------------------------------
        function ErrorCheckFinal(obj)
            obj.ErrorCheckName();
            
            % Find all acquisition files in group folder
            fileNames = findTypeFiles(obj.rootdir, ['.', obj.filetype], obj.excludedFolders);
            
            % Make a list of all files excluded from current data set  
            for ii = 1:length(fileNames)
                filefound = false;
                
                for jj = 1:length(obj.files)
                    if pathscompare(fileNames{ii}, [obj.rootdir, obj.files(jj).name])
                        filefound = true;
                        break;
                    end
                end
                
                for jj = 1:length(obj.filesErr)
                    if pathscompare(fileNames{ii}, [obj.rootdir, obj.filesErr(jj).name])
                        filefound = true;
                        break;
                    end
                end
                
                if ~filefound
                    obj.filesErr(end+1) = FileClass(fileNames{ii});
                    obj.filesErr(end).SetError('Invalid File Name');
                end
            end
        
        end
        
        
        
        % --------------------------------------------------------------------------
        function answer = AskToFixNameConflicts(obj, ii)
            global cfg
            
            ConfigFileClass
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
            [p2,f2] = fileparts(filesepStandard(obj.files(ii).rootdir,'nameonly:file'));
            [~,f3]  = fileparts(p2);
            if isfile_private(obj.files(ii).GetName())
                filetype = 'file'; %#ok<*PROPLC>
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
            for ii = 1:length(hc)
                
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
        function b = IsEmpty(obj)
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
                    end
                end
            end
        end
        
        
        
        % ----------------------------------------------------------
        function ErrorCheck(obj)
            errorIdxs = [];

            if isempty(obj.files)
                return
            end
                       
            % Assume constructor name follows from name of data format type
            constructor = sprintf('%sClass', [upper(obj.filetype(1)), obj.filetype(2:end)]);
            
            % Make sure function by that name exists; otherwise no way to
            % use it to check loadability
            if isempty(which(constructor))
                return;
            end
            
            % Try to create object of data filetype and load data into it
            msg = 'Please wait while we check group folder for valid data files ...';
            hwait = waitbar_improved(0, msg);
            dataflag = false;
            for ii = 1:length(obj.files)
                if obj.files(ii).isdir
                    continue;
                end
                if obj.files(ii).IsValidated()
                    dataflag = true;
                    continue;
                end
                filename = [obj.rootdir, obj.files(ii).name]; %#ok<NASGU>
                eval( sprintf('o = %s(filename);', constructor) );
                if  o.GetError() < 0
                    obj.logger.Write('DataFilesClass.ErrorCheck - ERROR: In file "%s" %s. File will not be added to data set\n', obj.files(ii).name, o.GetErrorMsg());
                    errorIdxs = [errorIdxs, ii]; %#ok<AGROW>
                elseif  contains(o.GetErrorMsg(), '''data'' field corrupt and unusable')                    
                    obj.logger.Write('DataFilesClass.ErrorCheck - WARNING: In file "%s" %s. File will not be added to data set\n', obj.files(ii).name, o.GetErrorMsg());
                    errorIdxs = [errorIdxs, ii]; %#ok<AGROW>
                elseif  contains(o.GetErrorMsg(), '''data'' field is invalid')                    
                    obj.logger.Write('DataFilesClass.ErrorCheck - WARNING: In file "%s" %s. File will not be added to data set\n', obj.files(ii).name, o.GetErrorMsg());
                    errorIdxs = [errorIdxs, ii]; %#ok<AGROW>
                elseif ~isempty(o.GetErrorMsg())
                    obj.logger.Write('DataFilesClass.ErrorCheck - WARNING: In file  "%s"  %s. File will be added anyway.\n', obj.files(ii).name, o.GetErrorMsg());
                    dataflag = true;
                else
                    dataflag = true;
                end
                if ~isempty(o.GetErrorMsg())
                    obj.files(ii).SetError(o.GetErrorMsg());
                else
                    obj.files(ii).SetValid();                    
                end
                hwait = waitbar_improved(ii/length(obj.files), hwait, msg);
            end
            
            if dataflag==false
                obj.files = FileClass.empty();
                obj.nfiles = 0;
            else
                for jj = 1:length(errorIdxs)
                    obj.filesErr(end+1) = obj.files(errorIdxs(jj)).copy;
                end
            	obj.files(errorIdxs) = [];
                obj.nfiles = obj.nfiles - length(errorIdxs);
            end
            close(hwait);

            obj.logger.Write('\n');
            
        end
        
        
        % ----------------------------------------------------------
        function err = GetError(obj)
            err = -1;
            if isempty(obj)
                return;
            end
            err = obj.err;
        end
                
        
        % ----------------------------------------------------------
        function PrintFolderStructure(obj, options)
            if ~exist('options','var')
                options = '';
            end
            stepsize = 3;
            obj.logger.Write('\n');
            obj.logger.Write('DataTreeClass - Data Set Folder Structure:\n');
            for ii = 1:length(obj.files)
                k = length(find(obj.files(ii).name=='/'));   
                if ii<10
                    j=3; 
                elseif ii>9 && ii<100
                    j=2;
                else
                    j=3;
                end
                if optionExists(options, 'flat')
                    obj.logger.Write(sprintf('%d.%s%s\n', ii, blanks(j), obj.files(ii).name));
                else
                    if ii<10
                        j=3; 
                    elseif ii>9 && ii<100
                        j=2; 
                    else 
                        j=3; 
                    end
                    if optionExists(options, 'numbered')
                        n = k*stepsize+stepsize+j;
                        obj.logger.Write(sprintf('%d.%s%s\n', ii, blanks(n), obj.files(ii).filename));
                        c = c+1;
                    else
                        n = k*stepsize+stepsize;
                        obj.logger.Write(sprintf('%d.%s%s\n', ii, blanks(n), obj.files(ii).filename));
                    end
                end
            end
            obj.logger.Write('\n');
        end

        
        
        % ----------------------------------------------------------
        function Copy(obj, obj2)
            obj.files       = obj2.files.copy();
            obj.filesErr    = obj2.filesErr.copy();
            obj.filetype    = obj2.filetype;
            obj.nfiles      = obj2.nfiles;
            obj.err         = obj2.err;
            obj.errmsg      = obj2.errmsg;
            obj.dirFormats  = obj2.dirFormats;
            obj.changed     = obj2.changed;
        end
        
        
        
        % ----------------------------------------------------------
        function b = eq(obj, obj2)
            b = false;
            if length(obj.files) ~= length(obj2.files)
                return
            end
            if length(obj.filesErr) ~= length(obj2.filesErr)
                return
            end
            for ii = 1:length(obj.files)
                if obj.files ~= obj2.files
                    return
                end
            end
            for ii = 1:length(obj.filesErr)
                if obj.filesErr ~= obj2.filesErr
                    return
                end
            end
            if obj.filetype ~= obj2.filetype
                return
            end
            b = true;
        end
        
    end
        
    
    
    methods (Access = private)

        % ----------------------------------------------------------
        function InitLookupTable(obj)
            width = 4;
            if isempty(obj.lookupTable)
                obj.lookupTable = int32(zeros((10^width)-1, 1));
            else
                obj.lookupTable(:) = 0;                
            end
        end

        
        % ----------------------------------------------------------
        function AddLookupTable(obj, str)
            n = round(log10(length(obj.lookupTable)));
            obj.lookupTable(string2hash(str, n)) = 1;
        end

        
        % ----------------------------------------------------------
        function b = SearchLookupTable(obj, str)
            n = round(log10(length(obj.lookupTable)));
            b = obj.lookupTable(string2hash(str, n));
        end
        

        
        % ----------------------------------------------------------
        function Print(obj)
            for ii = 1:length(obj.files)
                if obj.files(ii).isdir
                    continue
                end
                fprintf('%s\n', obj.files(ii).name);                
            end
        end
               
    end
                        
end
