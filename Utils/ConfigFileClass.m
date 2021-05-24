classdef ConfigFileClass < FileClass
    
    properties
        linestr;
        params;
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = ConfigFileClass(filename0)
            obj.linestr = '';
            obj.params = [];
            obj.filename = '';
            
            % Error checks
            if ~exist('filename0','var') || isempty(filename0)
                if isdeployed()
                    filename0 = [getAppDir(), 'AppSettings.cfg'];
                else
                    filename0 = which('AppSettings.cfg');
                end
            end
                                    
            [pname, fname, ext] = fileparts(filename0); 
            if isempty(pname)
                pname = '.';
            end
            filename = [pname, '/', fname, ext];
            if ~obj.Exist(filename)
                if isempty(ext)
                    filename = [pname, '/', fname, '.cfg'];
                    if ~obj.Exist(filename)
                        return;
                    end
                end
            end
            obj.fid = fopen(filename,'rt');
            if obj.fid<0
                return;
            end

            % We have a filename of an existing readable file.
            try 
                obj.filename = filesepStandard(filename);
                obj.Parse();
            catch ME
                % In case of parsing error make sure to close file handle 
                % so we don't leave the application in a bad state, then rethrow error
                fclose(obj.fid);
	            rethrow(ME)
            end
            fclose(obj.fid);
            obj.fid = -1;
            obj.linestr = '';
        end
        
        
        % ----------------------------------------------------
        function Parse(obj)
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
            iP=1;
            obj.linestr = '';
            while ~obj.eof()
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Find next parameter's name %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while ~obj.isParamName()
                    obj.linestr = fgetl(obj.fid);
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
                    fp_previous = ftell(obj.fid);
                    obj.linestr = fgetl(obj.fid);
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
                        fseek(obj.fid, fp_previous, 'bof');
                        break;
                    end
                    val{ii} = obj.getParamValueFromLine();
                    ii = ii+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Assign name/value pair to next param %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.AddParam(name, val, valOptions, iP);
                                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Move on to the next Param %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.linestr = '';
                iP = iP+1;
            end            
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('options', 'var')
                options = '';
            end
            if strcmp(options, 'backup')
                copyfile(obj.filename, [obj.filename, '.bak'])
            end
            if obj.fid<0
                obj.fid = fopen(obj.filename, 'w');
            end
            if obj.fid<0
                return;
            end
            fprintf(obj.fid, '\n');
            for ii = 1:length(obj.params)
                if iscell(obj.params(ii).valOptions) && all(~cellfun(@isempty,obj.params(ii).valOptions))
                    fprintf(obj.fid, '%% %s # %s\n', obj.params(ii).name, strjoin(obj.params(ii).valOptions,', '));
                elseif iscell(obj.params(ii).valOptions) && all(cellfun(@isempty,obj.params(ii).valOptions))
                    fprintf(obj.fid, '%% %s #\n', obj.params(ii).name);
                else
                    fprintf(obj.fid, '%% %s\n', obj.params(ii).name);
                end
                for jj = 1:length(obj.params(ii).val)
                    fprintf(obj.fid, '%s\n', obj.params(ii).val{jj});
                end
                fprintf(obj.fid, '\n');
            end
            fprintf(obj.fid, '%% END\n');
            
            fclose(obj.fid);
            obj.fid = -1;
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
            obj.params = struct('name','','val',{{}},'valOptions',{{}});
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function AddParam(obj, name, val, valOptions, iP)
            if ~iscell(val)
                val = {val};
            end
            if ~exist('iP', 'var')
                iP = length(obj.params)+1;
            end
            if isempty(obj.params)
                obj.InitParams();
            end
            obj.params(iP).name = name;
            obj.params(iP).val = val;
            obj.params(iP).valOptions = valOptions;
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
        function SetValue(obj, paramName, val)
            if nargin<3
                return;
            end
            if ~ischar(paramName)
                return;
            end
            for ii = 1:length(obj.params)
                if strcmp(obj.params(ii).name, paramName)
                    obj.params(ii).val{1} = val;
                end
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
            if obj.fid>0
                fclose(obj.fid);                
            end
            obj.fid = -1;
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function Restore(obj)
            if exist([obj.filename, '.bak'], 'file')
                movefile([obj.filename, '.bak'], obj.filename)
            end
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function b = BackupExists(obj)
            b = exist([obj.filename, '.bak'], 'file');
        end
        
        
    end
end


