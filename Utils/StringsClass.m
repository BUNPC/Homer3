classdef StringsClass < handle
    properties
        c
    end
    
    methods
        
        % ------------------------------------------------------
        function obj = StringsClass(arg)
            if nargin==0
                obj.c = {};
                return;
            end
            obj.Initialize(arg);
        end
        
        
        % ------------------------------------------------------
        function obj = Initialize(obj, arg)
            if nargin==1
                obj.c = {};
                return;
            end            
            if iscell(arg)
                obj.c = arg;
            elseif iswholenum(arg) & isscalar(arg)
                obj.c = repmat({''}, arg, 1);
            end
        end
        
        
        % ------------------------------------------------------
        function Insert(obj, s, key, before_after)
            % 
            % Insert either a char string or a cell array of char strings
            % into StringClass object
            %
            if ~exist('s','var') || (~ischar(s) && ~iscell(s))
                return;
            end
            if iscell(s)
                for ii=1:length(s)
                    if ~ischar(s{ii})
                        return;                        
                    end
                end
            else
                s = {s};
            end
            
            if ~exist('key','var') || isempty(key)
                key = length(obj.c);
            end
            if ~exist('before_after','var') || isempty(before_after)
                before_after = 'after';
            end
            if isempty(obj.c)
                obj.c(1:length(s)) = s;
                return;
            end
            
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end

            % Now that we have the index insert s before or after the
            % element in obj.c with index idx.
            if strcmp(before_after,'before')
                if idx==1
                    obj.c = [s; obj.c];
                else
                    obj.c = [obj.c(1:idx-1); s; obj.c(idx:end)];
                end
            elseif strcmp(before_after,'after')
                if idx==length(obj.c)
                    obj.c = [obj.c; s];
                else
                    obj.c = [obj.c(1:idx); s; obj.c(idx+1:end)];
                end
            end
            
        end
               
        
        % ------------------------------------------------------
        function Delete(obj, key)
            if isempty(obj.c)
                return;
            end
            if ~exist('key','var') || isempty(key)
                key = [];
            end
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            obj.c(idx) = '';
        end
        
        
        % ------------------------------------------------------
        function Move(obj, key1, key2)            
            if length(obj.c)<2
                return;
            end
            
            % Get index of element to move
            if ~exist('key1','var') || isempty(key1)
                key1 = [];
            end
            idx1 = obj.GetIdx(key1,1);
            if isempty(idx1)
                return;
            end
            
            % Get index of destination element
            if ~exist('key2','var') || isempty(key2)
                key2 = [];
            end
            idx2 = obj.GetIdx(key2,2);
            if isempty(idx2)
                return;
            end
            
            % Operation to move element to its own index not defined
            if idx1==idx2
                return;
            end
            
            if idx1<idx2
                before_after = 'after';
                idx3 = idx1;
            else
                before_after = 'before';
                idx3 = idx1+1;
            end
            
            % Get value 
            obj.Insert(obj.c{idx1}, idx2, before_after);
            obj.Delete(idx3);            
        end

        
        % ------------------------------------------------------
        function val = GetVal(obj, key)
            val = '';
            if isempty(obj.c)
                return;
            end
            if ~exist('key','var') || isempty(key)
                key = [];
            end
            idx = obj.GetIdx(key);
            if isempty(idx)
                return;
            end
            val = obj.c{idx};
        end
        
        
        
        % ------------------------------------------------------
        function val = Get(obj)
            val = {};
            if isempty(obj.c)
                return;
            end
            val = obj.c;
        end
        
        
        
        % ------------------------------------------------------
        function idx = GetIdx(obj, key, occur)
            %
            % Input:
            %    occur - If there are mutiple occurrences if key in obj.c
            %            tells which one to set idx to.
            idx = [];
            if ~exist('key','var') || isempty(key)
                key = 1;
            end
            if ~exist('occur','var') || isempty(occur) || ~iswholenum(occur)
                occur = 1;
            end
            if ischar(key)
                k = find(strcmp(obj.c, key));
                if isempty(k)
                    return
                end
                if occur>length(k)
                    occur = length(k);
                end
                key = k(occur);
            end
            if ~iswholenum(key) || key<1 || key>length(obj.c)
                return;
            end
            idx = key;
        end
        
    end
end

