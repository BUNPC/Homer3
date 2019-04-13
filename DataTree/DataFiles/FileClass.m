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
        idx
        subjdir
        subjdiridx
        filename
        map2group
        pathfull
    end
    
    methods

        function obj = FileClass(file_struct)

            obj.name       = '';
            obj.date       = '';
            obj.bytes      = 0;
            obj.isdir      = 0;
            obj.datenum    = 0;
            
            obj.idx        = 0;
            obj.subjdir    = '';
            obj.subjdiridx = 0;
            obj.filename   = '';
            obj.map2group  = struct('iSubj',0,'iRun',0);
            obj.pathfull   = '';

            if ~exist('file_struct','var') || isempty(file_struct)
                return;
            end

            % Copy all fields of file_struct that exist in this class to this object. 
            fields = propnames(file_struct);
            for ii=1:length(fields)
                if isproperty(obj, fields{ii})
                    eval( sprintf('obj.%s = file_struct.%s;', fields{ii}, fields{ii}) );
                end
            end

            % Now assign all the properies specific to this class
            obj.idx = 0;
            obj.subjdir = '';
            obj.subjdiridx = 0;
            obj.filename = obj.name;
            obj.map2group = struct('iSubj',0,'iRun',0);
            if obj.isdir
                obj.pathfull = fileparts(fileparts(fullpath(obj.name)));
            else
                obj.pathfull = fileparts(fullpath(obj.name));
            end

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
        function p = GetFilesPath(obj)
            p = obj.pathfull;            
        end
        
    end
    
end