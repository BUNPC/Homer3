classdef ConfigFileClass < FileClass
    
    properties
        linestr;
        sections;
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = ConfigFileClass(filename0)
            obj.linestr = '';
            obj.sections = struct('name','','val','','param','');
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
            % Rule 2:
            % =======
            % % name1 # param1
            % % END
            %
            % Rule 3:
            % =======
            % % name1 # param1
            % val11
            % % END
            %
            % Rule 4:
            % =======
            % % name1 # param1
            % val11
            % val12
            % ....
            % val1M
            % % END
            %
            % Rule 5:
            % =======
            % % name1 # param1
            % val11
            % val12
            % ....
            % val1M
            %
            % % name2 # param2
            % val21
            % val22
            % ....
            % val2M
            %
            %  .....
            %
            % % nameN # paramN
            % valN1
            % valN2
            % ....
            % valNM
            %
            % % END
            obj.err = 0;
            iP=1;
            obj.linestr = '';
            while ~obj.eof()
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Find next parameter's name %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while ~obj.isSectionName()
                    obj.linestr = fgetl(obj.fid);
                    if obj.eof()
                        obj.ExitWithError(1);
                        return;
                    end
                    if obj.endOfConfig()
                        obj.ExitWithError();
                        return;
                    end
                    if obj.isSectionVal()
                        obj.ExitWithError(2);
                        return;
                    end
                end
                name = obj.getSectionNameFromLine();
                param = obj.getSectionParamFromLine();
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Find next parameter's value %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ii=1;
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
                    if obj.isSectionName()
                        fseek(obj.fid, fp_previous, 'bof');
                        break;
                    end
                    val{ii} = obj.getSectionValueFromLine();
                    ii=ii+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Assign name/value pair to next param %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.sections(iP).name = name;
                obj.sections(iP).param = param;
                obj.sections(iP).val = val;
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Move on to the next Section %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.linestr='';
                iP=iP+1;
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
            for ii=1:length(obj.sections)
                if iscell(obj.sections(ii).param) && all(~cellfun(@isempty,obj.sections(ii).param))
                    fprintf(obj.fid, '%% %s # %s\n', obj.sections(ii).name, strjoin(obj.sections(ii).param,', '));
                elseif iscell(obj.sections(ii).param) && all(cellfun(@isempty,obj.sections(ii).param))
                    fprintf(obj.fid, '%% %s #\n', obj.sections(ii).name);
                else
                    fprintf(obj.fid, '%% %s\n', obj.sections(ii).name);
                end
                for jj=1:length(obj.sections(ii).val)
                    fprintf(obj.fid, '%s\n', obj.sections(ii).val{jj});
                end
                fprintf(obj.fid, '\n');
            end
            fprintf(obj.fid, '%% END\n');
            
            fclose(obj.fid);
            obj.fid = -1;
        end
        
        
        
        % -------------------------------------------------------------------------------------------------
        function ExitWithError(obj, err)
            obj.linestr='';
            if nargin==1
                return;
            end
            obj.err = err;
        end
        
    end
    
    
    methods
        
        % -------------------------------------------------------------------------------------------------
        function b = isSectionName(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            for ii=1:length(obj.linestr)
                if obj.linestr(ii)~=' '
                    break;
                end
            end
            if obj.linestr(ii)=='%'
                b=true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = isSectionVal(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            if isalnum(obj.linestr(1))
                b=true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = endOfConfig(obj)
            b = false;
            if isempty(obj.linestr)
                return;
            end
            
            % Do not remove spaces from section name 
            % k = find(obj.linestr==' ');
            % obj.linestr(k)=[];
            if strcmpi(obj.linestr,'%end')
                b=true;
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function b = eof(obj)
            b = false;
            if obj.linestr==-1
                b=true;
            end
        end
            
        
        % -------------------------------------------------------------------------------------------------
        function name = getSectionNameFromLine(obj)
            name = '';
            if isempty(obj.linestr)
                return;
            end
            
            ii=1;
            while ii<length(obj.linestr) && obj.linestr(ii)~='%'
                ii=ii+1;
            end
            while ii<length(obj.linestr) && ~isalnum(obj.linestr(ii))
                ii=ii+1;
            end
            jj=ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r')) && ~strcmp(obj.linestr(jj),'#')
                jj=jj+1;
            end
            if strcmp(obj.linestr(jj),'#')
                jj = jj-2;
            end
            name = strtrim_improve(obj.linestr(ii:jj));
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function param = getSectionParamFromLine(obj)
            param = '';
            if isempty(obj.linestr)
                return;
            end
            
            ii=1;
            while ii<length(obj.linestr) && obj.linestr(ii)~='#'
                ii=ii+1;
            end
            while ii<length(obj.linestr) && ~isalnum(obj.linestr(ii))
                ii=ii+1;
            end
            jj=ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r'))
                jj=jj+1;
            end
            if ii == jj && strcmp(obj.linestr(ii),'#')
                param = cell(1,1);
            elseif ii == jj
                param = [];
            else
                param = strtrim_improve(obj.linestr(ii:jj));
                param = split(param,', ');
            end
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = getSectionValueFromLine(obj)
            val = '';
            if isempty(obj.linestr)
                return;
            end
            
            ii=1;
            while ii<length(obj.linestr) && obj.linestr(ii)==' '
                ii=ii+1;
            end
            jj=ii;
            while jj<length(obj.linestr) && (obj.linestr(jj)~=newline || obj.linestr(jj)~=sprintf('\r'))
                jj=jj+1;
            end
            val = obj.linestr(ii:jj);
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = GetValue(obj, section)
            val = '';
            if nargin<2
                return;
            end
            if ~ischar(section)
                return;
            end
            for ii=1:length(obj.sections)
                if strcmp(obj.sections(ii).name, section)
                    if isempty(obj.sections(ii).val)
                        return;
                    end
                    val = obj.sections(ii).val{1};
                end
            end
        end

                
        % -------------------------------------------------------------------------------------------------
        function SetValue(obj, section, val)
            if nargin<3
                return;
            end
            if ~ischar(section)
                return;
            end
            for ii=1:length(obj.sections)
                if strcmp(obj.sections(ii).name, section)
                    obj.sections(ii).val{1} = val;
                end
            end
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


