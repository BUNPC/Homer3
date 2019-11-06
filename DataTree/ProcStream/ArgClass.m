classdef ArgClass < matlab.mixin.Copyable
    
    properties
        str
        vars
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ArgClass(varargin)
            obj.str    = '';
            obj.vars   = struct('name','','help','');
            if nargin==0
                return;
            elseif nargin==1
                obj.str   = varargin{1};
            elseif nargin==2
                obj.str   = varargin{1};
                obj.vars  = varargin{2};
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = Encode(obj)
            str = obj.str;
        end
 
    end
end