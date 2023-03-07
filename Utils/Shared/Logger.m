
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Logger < handle
    properties
        appname
        filename
        fhandle
        options
        DEBUG
        chapter
    end
    
    methods
        
        
        % -------------------------------------------------
        function self = Logger(appname, options)
            
            if ~exist('appname','var')
                appname = 'History';
            end
                                       
            % Construct log file name
            [pname, fname0] = fileparts(appname);
            fname = fname0;
            if ~ispathvalid(pname)
                pname = getAppDir();
                if isempty(pname)
                    fname = which([fname0, '.m']);
                    [pname, fname] = fileparts(fname);
                end
                if isempty(pname)
                    pname = filesepStandard(pwd);
                end
            end
           
            self.filename = [filesepStandard(pname), fname, '.log'];
            self.appname = fname;           
            
            % Check if log file for this application already exists - if it does close any open handles and delete it 
            % so you can start fresh
            if exist(self.filename, 'file') == 2
                fds = fopen('all');
                for ii = 1:length(fds)
                    filename = fopen(fds(ii));
                    if pathscompare(filename, self.filename)
                        fclose(fds(ii));
                        warning('off','MATLAB:DELETE:Permission');
                        delete(self.filename)
                        warning('on','MATLAB:DELETE:Permission');
                    end
                end
            end
            
            
            try
                self.fhandle = fopen(self.filename, 'wt');
            catch ME
                fprintf('Failed to open log file.\n');
                fprintf('    %s\n', ME.message);
                fprintf('    Will print output only to console\n');
                self.fhandle = -1;
            end
            
            self.options = struct(...
                'NULL',-1, ...
                'CONSOLE_ONLY',1, ...
                'FILE_ONLY',2, ... 
                'DEBUG',4, ...
                'PROGRESS_BAR',8, ...
                'CONSOLE_AND_FILE',[], ...
                'value',[]);
            self.options.CONSOLE_AND_FILE = bitor(self.options.FILE_ONLY, self.options.CONSOLE_ONLY);
            if ~exist('options','var') || isempty(options)
                options = self.options.CONSOLE_AND_FILE;
            end
            self.options.value = options;
            
            self.DEBUG = 0;            
            self.chapter = struct('maxsize',1e6, 'offset',0, 'number',1);
        end
        
        
               
        % -------------------------------------------------
        function val = Filter(self, options)
            % Value of options arg overrides inetrnal options setting
            if ~exist('options','var') || isempty(options)
                val = self.options.value;
            end
            if options == self.options.DEBUG
                val = self.options.CONSOLE_AND_FILE;
            elseif options == self.options.PROGRESS_BAR
                val = bitor(options, self.options.CONSOLE_AND_FILE);
            elseif self.options.value == self.options.NULL
                val = self.options.NULL;
            end
        end
        
                
        
        % -------------------------------------------------
        function Write(self, s, varargin) %#ok<*INUSL>
            if iscell(s)
                s = [s{:}]; %#ok<NASGU>
            end
            vars = '';
            for ii = 1:length(varargin)
                varargin{ii} = replaceSpecialChars(varargin{ii});
                if isempty(vars)
                    if ischar(varargin{ii})
                        vars = sprintf('''%s''', varargin{ii});
                    elseif isnumeric(varargin{ii})
                        vars = sprintf('%s', num2str(varargin{ii}));
                    end
                else
                    if ischar(varargin{ii})
                        vars = sprintf('%s, ''%s''', vars, varargin{ii});
                    elseif isnumeric(varargin{ii})
                        vars = sprintf('%s, %s', vars, num2str(varargin{ii}));
                    end
                end
            end
            if isempty(vars)
                s = eval( sprintf('sprintf(s)') );
            else
                s = eval( sprintf('sprintf(s, %s)', vars) );
            end
            if s(end)~=sprintf('\n') %#ok<SPRINTFN>
                s = sprintf('%s\n', s);
            end
            self.WriteStr(s)
        end
        
        
        
        % -------------------------------------------------
        function WriteNoNewline(self, s, options, hwait)
            if ~exist('options','var')
                options = [];
            end
            if ~exist('hwait','var')
                hwait = [];
            end
            self.WriteStr(s, options, hwait)
        end
        
        
        
        % -------------------------------------------------
        function WriteStr(self, s, options, hwait)
            if ~exist('options','var')
                options = [];
            end
            if ~exist('hwait','var')
                hwait = [];
            end
            options = self.Filter(options);
            
            if options == self.options.NULL
                return
            end
            if bitand(options, self.options.FILE_ONLY) > 0
                self.CheckFileSize()
                if self.fhandle > 0
                    fprintf(self.fhandle, s);
                end
            end
            if bitand(options, self.options.CONSOLE_ONLY) > 0
                fprintf(s);
            end
            if bitand(options, self.options.PROGRESS_BAR) > 0
                if ishandles(hwait)
                    waitbar_improved(0, hwait, s);
                end
            end
        end
        
        
        
        % -------------------------------------------------
        function WriteNoFmt(self, s, options, hwait)
            if ~exist('options','var')
                options = [];
            end
            if ~exist('hwait','var')
                hwait = [];
            end
            if s(end)~=sprintf('\n') %#ok<SPRINTFN>
                s = sprintf('%s\n', s);
            end            
            self.WriteStr(s, options, hwait)
        end
        
                
        
        % -------------------------------------------------
        function ct = CurrTime(self, msg, options, hwait)
            ct = '';
            if ~exist('msg','var')
                msg = [];
            end
            if ~exist('options','var')
                options = [];
            end
            
            options = self.Filter(options);
            
            if options == self.options.NULL
                return
            end
            try
                ct = char(datetime(datetime, 'Format','MMMM d, yyyy, HH:mm:ss'));
            catch
                ct = "";
            end
            if isempty(msg)
                s = sprintf('\n%s\n', ct);
            else
                i = find(msg == ':');
                if ~isempty(i)
                    s =  sprintf('\n%s%s - %s\n', msg(1:i+1), ct, msg(i+2:end));
                else
                    s =  sprintf('\n%s:  %s\n', ct, msg);
                end
            end
            if bitand(options, self.options.FILE_ONLY) > 0
                self.CheckFileSize()
                if self.fhandle > 0
                    fprintf(self.fhandle, s);
                end
            end
            if bitand(options, self.options.CONSOLE_ONLY) > 0
                fprintf(s);
            end
            if bitand(options, self.options.PROGRESS_BAR) > 0
                if ishandles(hwait)
                    waitbar_improved(0, hwait, s);
                end
            end
        end
        
        
        
        % -------------------------------------------------
        function Error(self, msg, options, hwait)
            if self.fhandle < 0
                return;
            end
            if ~exist('options','var')
                options = [];
            end
            options = self.Filter(options);
            
            if options == self.options.NULL
                return
            end
            try
                ct = char(datetime(datetime, 'Format','MMMM d, yyyy, HH:mm:ss'));
            catch
                ct = "";
            end
            s =  sprintf('\n%s:  %s', ct, msg);
            
            if bitand(options, self.options.FILE_ONLY) > 0
                self.CheckFileSize()
                if self.fhandle > 0
                    fprintf(self.fhandle, s);
                end
            end
            if bitand(options, self.options.CONSOLE_ONLY) > 0
                fprintf(s);
            end
            if bitand(options, self.options.PROGRESS_BAR) > 0
                if ishandles(hwait)
                    waitbar_improved(0, hwait, s);
                end
            end
        end
        
        
        
        % -------------------------------------------------
        function Open(self)
            try
                self.fhandle = fopen(self.filename, 'wt');
            catch ME
                fprintf('Failed to open log file.\n');
                fprintf('    %s\n', ME.message);
                fprintf('    Will print output only to console\n');
                self.fhandle = -1;
            end
        end
        

        
        % -------------------------------------------------
        function Close(self, appname)
            if ~exist('appname','var') || isempty(appname)
                appname = self.appname;
            end
            
            % If appname is passed and does not equal the associated log
            % filename then it's not meant to closed in this call so exit 
            % without closing file handle
            [~, fname] = fileparts(self.filename);
            if ~strcmp(appname, fname)
                return;
            end
            
            if self.fhandle < 0
                return;
            end            
            if ~strcmp(self.appname, appname)
                return;
            end
            try
                fclose(self.fhandle);
            catch
            end            
            self.fhandle = -1;
        end
        
        
        
        % -------------------------------------------------
        function Delete(self, appname)
            if ~exist('appname','var') || isempty(appname)
                appname = self.appname;
            end
            
            % If appname is passed and does not equal the associated log
            % filename then it's not meant to closed in this call so exit 
            % without closing file handle
            [~, fname] = fileparts(self.filename);
            if ~strcmp(appname, fname)
                return;
            end
            
            if self.fhandle < 0
                return;
            end
            if ~strcmp(self.appname, appname)
                return;
            end
            self.Close(appname);
            try
                delete(self.filename);
            catch
            end
        end
        
        
        
        % -------------------------------------------------
        function SetDebugLevel(self, options)
            if ~exist('options','var') || isempty(options)
                options = self.CONSOLE_AND_FILE;
            end
            self.options.value = options;
        end
        
        
        
        % -------------------------------------------------
        function val = FileOnly(self)
            val = self.options.FILE_ONLY;
        end
        
        
        
        % -------------------------------------------------
        function val = Null(self)
            val = self.options.NULL;
        end
        
        
        
        % -------------------------------------------------
        function val = ConsoleOnly(self)
            val = self.options.CONSOLE_ONLY;
        end
        
        
        
        % -------------------------------------------------
        function val = ConsoleAndFile(self)
            val = self.options.CONSOLE_AND_FILE;
        end
        
        
        
        % -------------------------------------------------
        function val = Debug(self)
            val = self.options.DEBUG;
        end
        
        
        
        % -------------------------------------------------
        function val = ProgressBar(self)
            val = self.options.PROGRESS_BAR;
        end

        
        % ---------------------------------------------------------------
        function filename = GetFilename(obj)
            [~, filename] = fileparts(obj.filename);
        end
        
        

        % ---------------------------------------------------------------
        function InitChapters(self)
            if self.fhandle < 0
                return;
            end
            self.chapter.offset = ftell(self.fhandle);
            fprintf(self.fhandle, '\nLogger: Chapter %d\n', self.chapter.number);
        end

        
        
        % ---------------------------------------------------------------
        function ResetChapter(self)
            if self.fhandle < 0
                return;
            end
            self.chapter.number = self.chapter.number+1;
            fseek(self.fhandle, self.chapter.offset, 'bof');            
            fprintf(self.fhandle, '\nLogger: Chapter %d\n', self.chapter.number);
        end
        
        
        
        % ---------------------------------------------------------------
        function CheckFileSize(self)
            if self.fhandle < 0
                return;
            end
            try
                if ftell(self.fhandle) > self.chapter.maxsize
                    self.ResetChapter()
                end
            catch
                self.fhandle = -1;
            end
        end
    
        
        
        % ---------------------------------------------------------------
        function b = IsOpen(self)
            b = false;
            if isempty(self.fhandle)
                return
            end
            if self.fhandle < 0
                return; 
            end
            b = true;
        end
        
    end
end

