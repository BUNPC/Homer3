classdef FileClass < handle
    
    properties
        % Same properties as the fields in the file struct returned 
        % by matlab's dir function
        name
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
        function MapFile2Group(obj, iSubj, iRun)
            obj.map2group.iSubj = iSubj;
            if ~obj.isdir
                obj.map2group.iRun  = iRun;
            else
                obj.map2group.iRun  = 0;
            end
        end

    end
    
end