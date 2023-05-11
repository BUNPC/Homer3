classdef ConfigFileClass < handle
    
    properties
        filenames
        fids
        linestr;
        params;
        err
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = ConfigFileClass(rootdir)
            obj.linestr = '';
            obj.params = [];
            obj.filenames = {};
            
            % Error checks
            if ~exist('rootdir','var') || isempty(rootdir)
                if isdeployed()
                    rootdir = getAppDir();
                else
                    appname = which(getNamespace());
                    rootdir = fileparts(appname);
                end
            end
            obj.FindCfgFiles(rootdir);
            obj.Update();            
        end
        
        
        
        % ---------------------------------------------------
        function Update(obj)        
            kk = [];
            for ii = 1:length(obj.filenames)
                obj.fids(ii) = fopen(obj.filenames{ii},'rt');
                if obj.fids(ii)<0
                    kk = [kk, ii];
                    continue;
                end
                
                % We have a filename of an existing readable file.
                try
                    obj.Parse(ii);                    
                    fprintf('Loaded config file %s\n', obj.filenames{ii})
                catch ME
                    % In case of parsing error make sure to close file handle
                    % so we don't leave the application in a bad state, then rethrow error
                    obj.Close();
                    rethrow(ME)
                end
            end
            obj.Close();
            obj.linestr = '';
        end
        
        
        
        % ----------------------------------------------------
        function Parse(obj, iF)
            %
            % Parse(obj)
            %
            % Parse name/value pairs in config file. All values are interpreted as char
            % strings.
            %
            % Legal syntax has to fit one of the following 5 rules:
            %
            %
            % Rule 1:
            % =======
            % % END
            %
            %
            % Rule 2:
            % =======
            % % name1 # val11, val12, ... val1M
            %
            % % END
            %
            %
            % Rule 3:
            % =======
            % % name1
            % val11
            %
            % % END
            %
            %
            % Rule 2:
            % =======
            % % name1 # val11, val12, ... val1M
            %
            % % END
            %
            %
            % Rule 3:
            % =======
            % % name1 # val11, val12, ... val1M
            % val1i
            %
            % % END
            %
            %
            % Rule 4:
            % =======
            % % name1 # val11, val12, ... val1M
            % val1i
            %
            % % END
            %
            %
            % Rule 5:
            % =======
            % % name1 # val11, val12, ... val1M
            % val1i
            %
            % % name2 # val21, val22, ... val2M
            % val2i
            %
            %  .....
            %
            % % nameN # valN1, valN2, ... valNM
            % valNi
            %
            % % END
            %
            obj.err = 0;
            obj.linestr = '';
            while ~obj.eof()
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Find next parameter's name %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while ~obj.isParamName()
                    obj.linestr = fgetl(obj.fids(iF));
                    if obj.eof()
                        obj.ExitWithError(1);
                        return;
                    end
                    if obj.endOfConfig()
                        obj.ExitWithError();
                        return;
                    end
                    if obj.isParamVal()
                        obj.ExitWithError(2);
                        return;
                    end
                end
                name = obj.getParamNameFromLine();
                valOptions = obj.getParamValOptionsFromLine();
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Find next parameter's value %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ii = 1;
                obj.linestr = '';
                val = {};
                while 1
                    fp_previous = ftell(obj.fids(iF));
                    obj.linestr = fgetl(obj.fids(iF));
                    if isempty(obj.linestr)
                        continue;
                    end
                    if obj.eof()
                        obj.ExitWithError(1);
                        return;
                    end
                    if obj.endOfConfig()
                        fseek(obj.fid, fp_previous, 'bof');
                        break;
                    end
                    if obj.isParamName()
                        fseek(obj.fids(iF), fp_previous, 'bof');
                        break;
                    end
                    val{ii} = obj.getParamValueFromLine();
                    ii = ii+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Assign name/value pair to next param %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.AddParam(name, val, valOptions, iF);
                                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Move on to the next Param %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.linestr = '';
            end            
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('options', 'var')
                options = '';
            end
            for ii = 1:length(obj.fids)
                if strcmp(options, 'backup')
                    
                    copyfile(obj.filenames{ii}, [obj.filenames{ii}, '.bak'])
                    
                else
                    
                    if obj.fids(ii)<0
                        obj.fids(ii) = fopen(obj.filenames{ii}, 'w');
                    end
                    if obj.fids(ii)<0
                        continue;
                    end
                    for jj = 1:length(obj.params)
                        if obj.params(jj).iSrc ~= ii
                            continue
                        end
                        if iscell(obj.params(jj).valOptions) && all(~cellfun(@isempty,obj.params(jj).valOptions))
                            fprintf(obj.fids(ii), '%% %s # %s\n', obj.params(jj).name, strjoin(obj.params(jj).valOptions,', '));
                        elseif iscell(obj.params(jj).valOptions) && all(cellfun(@isempty,obj.params(jj).valOptions))
                            fprintf(obj.fids(ii), '%% %s #\n', obj.params(jj).name);
                        else
                            fprintf(obj.fids(ii), '%% %s\n', obj.params(jj).name);
                        end
                        for kk = 1:length(obj.params(jj).val)
                            fprintf(obj.fids(ii), '%s\n', obj.params(jj).val{kk});
                        end
                        fprintf(obj.fids(ii), '\n');
                    end
                    fprintf(obj.fids(ii), '%% END\n');                    
                    fclose(obj.fids(ii));
                    obj.fids(ii) = -1;
                    
                end
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function ExitWithError(obj, err)
            obj.linestr = '';
            if nargin==1
                return;
            end
            obj.err = err;
        end
        
    end
    
    
    
    methods
        
        % -------------------------------------------------------------------------------------------------
        function InitParams(obj)
            obj.params = struct('name','', 'val',{{}}, 'valOptions',{{}}, 'iSrc',0);
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function AddParam(obj, name, val, valOptions, iF)
            if ~iscell(val)
                val = {val};
            end
            iP = length(obj.params)+1;
            if isempty(obj.params)
                obj.InitParams();
            end
            obj.params(iP).name = name;
            obj.params(iP).val = val;
            obj.params(iP).valOptions = valOptions;
            obj.params(iP).iSrc = iF;
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function b = isParamName(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            for ii = 1:length(obj.linestr)
                if obj.linestr(ii) ~= ' '
                    break;
                end
            end
            if obj.linestr(ii) == '%'
                b = true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = isParamVal(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            if isalnum(obj.linestr(1))
                b = true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = endOfConfig(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            
            % Do not remove spaces from param name
            % k = find(obj.linestr==' ');
            % obj.linestr(k)=[];
            if strcmpi(obj.linestr,'%end')
                b = true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = eof(obj)
            b = false;
            if obj.linestr==-1
                b = true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function name = getParamNameFromLine(obj)
            name = '';
            if isempty(obj.linestr)
                return;
            end
            ii = 1;
            while ii<length(obj.linestr) && obj.linestr(ii)~='%'
                ii = ii+1;
            end
            while ii<length(obj.linestr) && ~isalnum(obj.linestr(ii))
                ii = ii+1;
            end
            jj = ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r')) && ~strcmp(obj.linestr(jj),'#')
                jj = jj+1;
            end
            if strcmp(obj.linestr(jj),'#')
                jj = jj-2;
            end
            name = strtrim_improve(obj.linestr(ii:jj));
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function valOptions = getParamValOptionsFromLine(obj)
            valOptions = '';
            if isempty(obj.linestr)
                return;
            end
            ii = 1;
            while ii<length(obj.linestr) && obj.linestr(ii)~='#'
                ii = ii+1;
            end
            while ii<length(obj.linestr) && ~isalnum(obj.linestr(ii))
                ii = ii+1;
            end
            jj = ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r'))
                jj = jj+1;
            end
            if ii == jj
                valOptions = {};
            else
                valOptions = strtrim_improve(obj.linestr(ii:jj));
                valOptions = split(valOptions,', ');
                for ii = 1:length(valOptions)
                    valOptions{ii} = strtrim_improve(valOptions{ii});
                end
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = getParamValueFromLine(obj)
            val = '';
            if isempty(obj.linestr)
                return;
            end
            ii = 1;
            while ii<length(obj.linestr) && obj.linestr(ii)==' '
                ii = ii+1;
            end
            jj = ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r'))
                jj = jj+1;
            end
            val = obj.linestr(ii:jj);
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = GetValue(obj, paramName)
            val = '';
            if nargin<2
                return;
            end
            if ~ischar(paramName)
                return;
            end
            for ii = 1:length(obj.params)
                if strcmp(obj.params(ii).name, paramName)
                    if isempty(obj.params(ii).val)
                        return;
                    end
                    val = obj.params(ii).val{1};
                end
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function valOptions = GetValueOptions(obj, paramName)
            valOptions = '';
            if nargin<2
                return;
            end
            if ~ischar(paramName)
                return;
            end
            for ii = 1:length(obj.params)
                if strcmpi(obj.params(ii).name, paramName)
                    valOptions = obj.params(ii).valOptions;
                    break;
                end
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function val = GetMultiValues(obj, paramName)
            val = '';
            if nargin<2
                return;
            end
            if ~ischar(paramName)
                return;
            end
            for ii = 1:length(obj.params)
                if strcmp(obj.params(ii).name, paramName)
                    if isempty(obj.params(ii).val)
                        return;
                    end
                    val = obj.params(ii).val;
                end
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function SetValue(obj, paramName, val, autosave)
            if nargin<3
                return;
            end
            if ~exist('autosave','var')
                autosave = 0;
            end
            if ischar(autosave) 
                if strcmpi(autosave,'autosave')
                    autosave = true;
                end
            else
                autosave = false;
            end
            
            if ~ischar(paramName)
                return;
            end
            for ii = 1:length(obj.params)
                if strcmp(obj.params(ii).name, paramName)
                    obj.params(ii).val{1} = val;
                end
            end
            
            if autosave
                obj.Save();
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function num = GetParamNum(obj)
            num = length(obj.params);
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function name = GetParamName(obj, idx)
            name = '';
            if isempty(obj)
                return;
            end
            if isempty(obj.params)
                return;
            end
            if nargin == 0
                idx = 1;
            end
            name = obj.params(idx).name;
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = GetParamValue(obj, idx)
            val = {};
            if isempty(obj)
                return;
            end
            if isempty(obj.params)
                return;
            end
            if nargin == 0
                idx = 1;
            end
            if ischar(idx)
                idx = obj.GetParamIdx(idx);
            end
            val = obj.params(idx).val;
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function valOptions = GetParamValueOptions(obj, idx)
            valOptions = {};
            if isempty(obj)
                return;
            end
            if isempty(obj.params)
                return;
            end
            if nargin == 0
                idx = 1;
            end
            valOptions = obj.params(idx).valOptions;
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function Close(obj)
            for ii = 1:length(obj.fids)
                if obj.fids(ii)>0
                    fclose(obj.fids(ii));
                end
                obj.fids(ii) = -1;
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function Restore(obj)
            for ii = 1:length(obj.filenames)
                if exist([obj.filenames{ii}, '.bak'], 'file')
                    movefile([obj.filenames{ii}, '.bak'], obj.filenames{ii})
                end
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function b = BackupExists(obj)
            b = 0;
            for ii = 1:length(obj.filenames)
                if exist([obj.filenames{ii}, '.bak'], 'file')
                    b = b+1;
                end
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = ChangedValue(obj, paramName, s)
            b = true;
            s2 = obj.GetValue(paramName);
            if length(s) ~= length(s2)
                return;
            end
            if ~strcmp(s, s2)
                return
            end
            b = false;
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = eq(obj, obj2)
            b = false;
            if ~isempty(obj) && isempty(obj2)
                return;
            end
            if isempty(obj) && ~isempty(obj2)
                return;
            end
            for ii = 1:length(obj.params)
                if ~strcmpi(obj.params(ii).name, obj2.params(ii).name)
                    return;
                end
                if ~strcmpi(obj.params(ii).val, obj2.params(ii).val)
                    return;
                end
            end
            b = true;
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = Modified(obj)
            obj2 = ConfigFileClass();
            if obj == obj2
                b = false;
            else
                b = true;
            end
        end

        
        % -------------------------------------------------------------------------------------------------
        function FindCfgFiles(obj, rootdir)
            if nargin == 1
                rootdir = pwd;
            end            
            if ~ispathvalid(rootdir, 'dir')
                return;
            end
            rootdir = filesepStandard(rootdir);
            
            if ispathvalid([rootdir, 'AppSettings.cfg'])
                obj.filenames{end+1,1} = [rootdir, 'AppSettings.cfg'];
            end
            dirs = dir([rootdir, '*']);
            for ii = 1:length(dirs)
                if ~dirs(ii).isdir
                    continue;
                end
                if strcmp(dirs(ii).name, '.')
                    continue;
                end
                if strcmp(dirs(ii).name, '.git')
                    continue;
                end
                if strcmp(dirs(ii).name, '..')
                    continue;
                end
                if strcmp(dirs(ii).name, 'submodules')
                    continue;
                end
                obj.FindCfgFiles([rootdir, dirs(ii).name]);
            end
        end
        
    end
end


