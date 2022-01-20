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

        
        % ----------------------------------------------------------------------------------
        function scorefinal = Compare(obj, obj2)
            v1 = obj.Extract();
            v2 = obj2.Extract();
            
            score = zeros(1, max([length(v1), length(v2)]));
            
            for ii = 1:length(v1)
                for jj = 1:length(v2)
                    if strcmp(v1{ii}, v2{jj})
                        if ii==jj
                            score(ii) = 1.00; 
                        else
                            score(ii) = 0.50;
                        end
                    end
                end
            end
            scorefinal = mean(score);
        end
 
        
        % ----------------------------------------------------------------------------------
        function args = Extract(obj)
            args = str2cell(obj.str,',');
            
            % Make sure cell array is a column vector. That the output
            % type expected by the calling function
            if size(args,1) > 1
                args = args';
            end
            if size(args, 1) > 0
                if args{1}(1)=='[' || args{1}(1)=='('
                    args{1}(1) = '';
                end
                if args{end}(end)==']'
                    args{end}(end) = '';
                end 
            end
        end        
    end
end

