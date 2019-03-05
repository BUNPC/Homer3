classdef LogClass < handle
    
    properties
        filename;
        fid;
        msg;
        options;
    end
    
    methods
        
        % ---------------------------------------------------------------
        function obj = LogClass(appdir, appname, options)
            if nargin == 0
                appdir = [pwd, '/'];
                appname = 'History';
                obj.options = 'file';
            elseif nargin==3
                obj.options = options;
            end
            obj.filename = [appdir, appname, '.log'];            
            if exist(obj.filename,'file')
                delete(obj.filename);
            end
            obj.fid = fopen(obj.filename, 'w');
            obj.msg = '';
        end
        
        
        % ---------------------------------------------------------------
        function Write(obj, msg)
            if isempty(msg)
                return;
            end
            obj.msg = msg;
            if obj.msg ~= sprintf('\n')
                linefeed = sprintf('\n');
            else
                linefeed = '';
            end
            if obj.fid>0
                fprintf(obj.fid, '%s%s', obj.msg, linefeed);
            end
            fprintf('%s%s', obj.msg, linefeed);
        end
        
        
        % ---------------------------------------------------------------
        function Clear(obj)
            obj.msg = '';
        end
        
        
        % ---------------------------------------------------------------
        function Close(obj)
            if obj.fid>0
                fclose(obj.fid);
            end
        end
        
        
        % ---------------------------------------------------------------
        function filename = GetFilename(obj)
            [~, filename] = fileparts(obj.filename);
        end
        
    end
    
end