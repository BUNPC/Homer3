classdef ParamClass < matlab.mixin.Copyable
    
    properties
        name
        value
        format
        help
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ParamClass(varargin)
            obj.name   = '';
            obj.value  = [];
            obj.format = '';
            obj.help   = '';
            
            if nargin==0
                return;
            elseif nargin==1
                obj.name   = varargin{1};
            elseif nargin==2
                obj.name   = varargin{1};
                obj.format = varargin{2};
            elseif nargin==3
                obj.name   = varargin{1};
                obj.format = varargin{2};
                obj.value  = varargin{3};
            end
        end
        
        % ----------------------------------------------------------------------------------
        % Override == operator: 
        % ----------------------------------------------------------------------------------
        function B = eq(obj, obj2)
            % Two parameters do not have to have the same value to be equal. 
            % Equal in this definitions means same param name, same type, 
            % same number and same general format (although don't need to 
            % be same precision for floats).
            B = false;
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            if length(obj.value) ~= length(obj2.value)
                return;
            end
            if ndims(obj.value) ~= ndims(obj2.value)
                return;
            end
            % if ~all(obj.value==obj2.value)
            %     return;
            % end
            if ~strcmp(obj.format, obj2.format)
                if obj.format(end)~=obj2.format(end)
                    return;
                end
            end
            B = true;
        end

        
        % ----------------------------------------------------------------------------------
        % Override ~= operator: 
        % ----------------------------------------------------------------------------------
        function B = ne(obj, obj2)
            if obj == obj2
                B = false;
            else
                B = true;
            end
        end
        
    end
end

