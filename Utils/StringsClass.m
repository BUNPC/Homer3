classdef StringsClass < handle
    properties
        c
        status
    end
    
    methods
        
        % ------------------------------------------------------
        function obj = StringsClass(arg)
            obj.status = 0;
            if nargin==0
                obj.c = {};
                return;
            end
            obj.Initialize(arg);
        end
        
        
        % ------------------------------------------------------
        function obj = Initialize(obj, arg)
            obj.status = 0;
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
        function idx = Insert(obj, s, key, before_after)
            % 
            % Insert either a char string or a cell array of char strings
            % into StringClass object. It returns the index of the inserted
            % entry or empty array if insertion is unsuccessful.
            %
            idx = [];
            
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
                idx = 1;
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
                    if iscolumn(obj.c)
                        obj.c = [s; obj.c];
                    else
                        obj.c = [s, obj.c];
                    end
                else
                    if iscolumn(obj.c)
                        obj.c = [obj.c(1:idx-1); s; obj.c(idx:end)];
                    else
                        obj.c = [obj.c(1:idx-1), s, obj.c(idx:end)];
                    end
                end
            elseif strcmp(before_after,'after')
                if idx==length(obj.c)
                    if iscolumn(obj.c)
                        obj.c = [obj.c; s];
                    else
                        obj.c = [obj.c, s];
                    end
                else
                    if iscolumn(obj.c)
                        obj.c = [obj.c(1:idx); s; obj.c(idx+1:end)];
                    else
                        obj.c = [obj.c(1:idx), s, obj.c(idx+1:end)];
                    end
                end
                
                % Update idx to the inserted entry
                idx = idx+1;
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
        
               
        % ------------------------------------------------------
        function maxlen = MaxColumnSizes(obj)
            maxlen = [];
            if isempty(obj.c)
                return;
            end
            maxlen = zeros( 1, length(find(obj.c{1}==':'))+1 );
            for ii=1:length(obj.c)
                obj.c{ii}(obj.c{ii}==' ') = '';
                k = [1, find(obj.c{ii}==':'), length(obj.c{ii})];
                len = diff(k);
                for jj=1:length(len)
                    if len(jj)>maxlen(jj)
                        if jj>1 && jj<length(len)
                            maxlen(jj) = len(jj)-1;
                        else
                            maxlen(jj) = len(jj);
                        end
                    end
                end
            end
        end
        
        
        % ------------------------------------------------------
        function Tabularize(obj)
            if length(obj.c)<1
                return;
            end            
            c0 = obj.c;
            maxlen = obj.MaxColumnSizes();
            for ii=1:length(obj.c)
                colvals = str2cell(obj.c{ii}, ':');
                if length(maxlen) ~= length(colvals)
                    fprintf('Cannot tabularize data: strings do not have same number of columns...\n');
                    obj.status = 1;
                    obj.c = c0;
                    return;
                end
                obj.c{ii} = '';
                for jj=1:length(maxlen)
                    colvals{jj} = strtrim(colvals{jj});
                    nspaces = maxlen(jj) - length(colvals{jj});
                    if jj<length(colvals)
                        obj.c{ii} = sprintf('%s%s%s : ', obj.c{ii}, colvals{jj}, blanks(nspaces));
                    else
                        obj.c{ii} = sprintf('%s%s', obj.c{ii}, colvals{jj});
                    end
                end
            end
        end
        
        
        
        % ------------------------------------------------------
        function b = IsMember(obj, s, delimiter)
            %
            % Syntax:
            %     b = IsMember(obj, s)
            %     b = IsMember(obj, s, delimiter)
            %
            % Description:
            %     Check if string s is a member of this StringsClass object. If the delimiter is 
            %     supplied the function subdivides the the strings of the cell array obj.c into 
            %     sections separated by the delimiter and checks each sections of s against the
            %     corresponding section of obj.c. 
            %
            % Example:
            %     s = StringsClass({'aaaa: bbbb: yyy';'wwwwww: nnnnn: eeeee';'GGGG: ooooooo: oswald'});
            %     s.Get()
            %     ===>   'aaaa: bbbb: yyy'
            %            'wwwwww: nnnnn: eeeee'
            %            'GGGG: ooooooo: oswald'
            %
            %     s.IsMember('wwwwww: nnnnn: eeeee') 
            %     ===>   1
            %
            %     s.IsMember('wwwwww: nnnnn:   eeeee  ')
            %     ===>   0
            %
            %     s.IsMember('wwwwww  nnnnn   eeeee')
            %     ===>   0
            %
            %     s.IsMember('wwwwww: nnnnn:   eeeee  ', ':')
            %     ===>   1
            %
            if ~exist('delimiter','var')
                delimiter='';
            end
            
            b = true;
            scolvals = str2cell(s, delimiter);
            for ii=1:length(obj.c)
                ccolvals = str2cell(obj.c{ii}, delimiter);
                if length(scolvals)==length(ccolvals)
                    flags = zeros(1,length(scolvals));
                    for jj=1:length(ccolvals)
                        if strcmp(strtrim(ccolvals{jj}), strtrim(scolvals{jj}))
                            flags(jj)=true;
                        end         
                    end
                    if all(flags)
                        return;
                    end
                end
            end
            b = false;
        end

        
        
        % ------------------------------------------------------
        function n = GetSize(obj)
            n = length(obj.c);
        end
        
        
        % ------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj.c)
                return
            end
            b = false;
        end
        
    end
end

