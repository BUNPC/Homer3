classdef ParamClass < matlab.mixin.Copyable
    
    properties
        name
        value       % Current value of parameter
        default     % Default value loaded from the function helpstring
        format      % printf-format string for scalar(s) in value
        help
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ParamClass(varargin)
            % FuncCallClass's Encode handles ParamClass construction
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
            elseif nargin==4
                obj.name   = varargin{1};
                obj.format = varargin{2};
                obj.value  = varargin{3};
                obj.default = varargin{4};
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
            B = 0;            
            if ~strcmp(obj.name, obj2.name)
                return;
            end
            if length(obj.value) ~= length(obj2.value)
                return;
            end
            if ndims(obj.value) ~= ndims(obj2.value)
                return;
            end
            if isa(obj2, 'ParamClass')
                if ~strcmp(obj.format, obj2.format)
                    if obj.format(end)~=obj2.format(end)
                        return;
                    end
                end
            elseif isstruct(obj2)
                if ~all(obj.value==obj2.value)
                    B = -1;
                    return;
                end
            end
            B = 1;
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
        
        % ----------------------------------------------------------------------------------
        function str = GetFormattedValue(obj)
            % Returns the string version of the value using the format
            % property, including brackets for arrays
            valstr = sprintf(obj.format, obj.value);
            if length(obj.value) > 1
                str = ['[', valstr, ']'];
            else
                str = valstr;
            end
        end
        
        % ----------------------------------------------------------------------------------
        function val = GetName(obj)
            val = obj.name;
        end
        
        % ----------------------------------------------------------------------------------
        function val = GetValue(obj)
            val = obj.value;
        end
        
        % ----------------------------------------------------------------------------------
        function val = GetFormat(obj)
            val = obj.format;
        end

        % ----------------------------------------------------------------------------------
        function val = GetDefault(obj)
            val = obj.default;
        end

        % ----------------------------------------------------------------------------------
        function err = Edit(obj, val)
            % Assign a new value to the parameter, affecting both the value
            % and format
            obj.value = val;
            eachformat = strsplit(obj.format);
            formatlen = length(val);
            obj.format = strtrim(repmat([eachformat{1}, ' '], 1, formatlen));
            err = 0;  % Error checking i.e. max length
        end
        
        % ----------------------------------------------------------------------------------
        function str = Encode(obj)
            str = '';
            formatarr =  str2cell(obj.format,' ');
            if length(obj.value) ~= length(formatarr)
                return
            end
            formatstr =  '';
            valuestr = '';
            for ii=1:length(obj.value)
                if ii<2
                    formatstr = formatarr{ii};
                    valuestr = num2str(obj.value(ii));
                else
                    formatstr = sprintf('%s_%s', formatstr, formatarr{ii});
                    valuestr = sprintf('%s_%s', valuestr, num2str(obj.value(ii)));                    
                end
            end
            str = sprintf('%s %s %s', obj.name, formatstr, valuestr);
        end
        
        
        % ----------------------------------------------------------------------------------
        function scorefinal = Compare(obj, obj2)
            nameMaxScore   = 0.50;
            formatMaxScore = 0.20;
            valueMaxScore  = 0.30;
            
            nsteps = max(length(obj.value), length(obj2.value));
            stepsize = valueMaxScore/nsteps;
            maxscore = [nameMaxScore, formatMaxScore, stepsize+zeros(1,nsteps)]; 
            
            score = zeros(1, length(maxscore));
            kk = 1;
            
            if ~strcmp(obj.name, obj2.name)
                scorefinal = 0;
                return
            else
                score(kk) = maxscore(kk);
            end
            kk = kk+1;
            
            if ~strcmp(obj.format, obj2.format)
                score(kk) = 0;
            else
                score(kk) = maxscore(kk);
            end
            kk = kk+1;
            
            for ii = 1:length(obj.value)
                if ii <= length(obj2.value)
                    if obj.value(ii) == obj2.value(ii)
                        score(kk) = maxscore(kk);
                    else
                        score(kk) = maxscore(kk)/2;
                    end
                else
                    score(kk) = 0;
                end
                kk = kk+1;
            end            
            scorefinal = sum(score);
        end
                
    end
end

