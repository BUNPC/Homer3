classdef ConfigFileClass < FileClass
    
    properties
        linestr;
        sections;
        err;
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = ConfigFileClass(filename0)
            obj.linestr = '';
            obj.sections = struct('name','','val','');
            obj.filename = '';
            
            % Error checks
            if nargin==0
                filename0 = which('AppSettings.cfg');
            elseif nargin>1
                obj.params = params;
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
            obj.fid = fopen(filename,'r');
            if obj.fid<0
                return;
            end

            % We have a filename of an exiting readdable file. 
            obj.filename = filename;
            obj.ParseFile();

            fclose(obj.fid);
            obj.fid = -1;
            obj.linestr = '';            
        end
        
        
        % ----------------------------------------------------
        function ParseFile(obj)
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
            % % name1
            % % END
            %
            % Rule 3:
            % =======
            % % name1
            % val11
            % % END
            %
            % Rule 4:
            % =======
            % % name1
            % val11
            % val12
            % ....
            % val1M
            % % END
            %
            % Rule 5:
            % =======
            % % name1
            % val11
            % val12
            % ....
            % val1M
            %
            % % name2
            % val21
            % val22
            % ....
            % val2M
            %
            %  .....
            %
            % % nameN
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
                obj.sections(iP).val = val;
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Move on to the next Section %%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.linestr='';
                iP=iP+1;
            end            
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function WriteFile(obj)
            if obj.fid<0
                obj.fid = fopen(obj.filename, 'w');
            end
            if obj.fid<0
                return;
            end
            fprintf(obj.fid, '\n');
            for ii=1:length(obj.sections)
                fprintf(obj.fid, '%% %s\n', obj.sections(ii).name);
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
            while jj<length(obj.linestr) && (obj.linestr(jj)~=sprintf('\n') || obj.linestr(jj)~=sprintf('\r'))
                jj=jj+1;
            end
            name = strtrim_improve(obj.linestr(ii:jj));
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
            while jj<length(obj.linestr) && (obj.linestr(jj)~=sprintf('\n') || obj.linestr(jj)~=sprintf('\r'))
                jj=jj+1;
            end
            val = obj.linestr(ii:jj);
        end
        
        
        % -------------------------------------------------------------------------------------------------
        function val = GetValue(obj, section)
            val = {};
            if nargin<2
                return;
            end
            if ~ischar(section)
                return;
            end
            for ii=1:length(obj.sections)
                if strcmp(obj.sections(ii).name, section)
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
        
        
        
        
    end
end


