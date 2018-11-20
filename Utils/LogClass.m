classdef LogClass < handle
    
    properties
        fid;
        msg;
        options;
    end
    
    methods
        
        function obj = LogClass(appdir, appname, options)
            
            if nargin == 0
                appdir = [pwd, '/'];
                appname = 'debug';
                obj.options = 'file';
            else
                obj.options = options;
            end
            
            if exist([appdir, appname, '.log'],'file')
                delete([appdir, appname, '.log']);
            end
            
            obj.fid = fopen([appdir, appname, '.log'], 'w');
            obj.msg = '';
            
        end
        
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
            % fprintf(obj.fid, '%s%s', obj.msg, linefeed);
            fprintf('%s%s', obj.msg, linefeed);
            
        end
        
        
        function Clear(obj)
            
            obj.msg = '';
            
        end
        
        
        function delete(obj)
            
            fclose(obj.fid);
            
        end
        
    end
    
end