classdef TableCell < handle
    properties
        name
        width
        spaces
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = TableCell(name, width)
            if nargin==0
                name = '';
                width = 10;
            end
            if nargin==1
                width = 10;
            end
            obj.name = name;
            obj.width = width;
            obj.spaces = obj.width - length(obj.name);
        end
        
        
        % -------------------------------------------------------
        function Write(obj, fd)
            fprintf(fd,'%s%s\t', blanks(obj.spaces), obj.name);
        end
                
    end
end