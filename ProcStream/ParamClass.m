classdef ParamClass
    properties
        name
        value
        format
        help
    end
    
    methods
        
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
        
    end
end

