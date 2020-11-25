classdef FuncRegEntryClass < matlab.mixin.Copyable
    
    properties
        name
        uiname
        usageoptions
        params
        help
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegEntryClass(varargin)
            if nargin==0
                return;
            end
            if ischar(varargin{1})
                [~,funcname] = fileparts(varargin{1});
                obj.name = funcname;
                obj.uiname = '';
                obj.usageoptions = {};
                obj.params       = {};
                obj.help = FuncHelpClass(funcname);
                obj.SetUsageFromHelp();
                obj.EncodeUsage();
            elseif isa(varargin{1}, 'FuncRegEntryClass')
                obj.Copy(varargin{1});
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetUsageFromHelp(obj)
            %
            % Data flow for SetUsageFromHelp:
            %   obj.help  --> SetUsageFromHelp() --> {obj.usageoptions, obj.params}
            %
            [paramname, valformat] = obj.help.GetParamUsage();
            for ii=1:length(paramname)
                obj.params{ii,1} = paramname{ii};
                obj.params{ii,2} = valformat{ii};
            end
            [usage, friendlyname] = obj.help.GetUsageOptions();
            for ii=1:length(usage)
                obj.usageoptions{ii,1} = friendlyname{ii};
                obj.usageoptions{ii,2} = usage{ii};
            end
            obj.uiname = obj.help.GetUiname();
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function EncodeUsage(obj)
            % This function takes all the usage cases from the help sections "USAGE OPTIONS"
            % and "PARAMETERS" and encodes them into registry language:
            %
            % Here's the internal data flow for EncodeUsage:
            %   {obj.usageoptions{:,2}, obj.params} --> EncodeUsage() --> obj.usageoptions{:,3}
            %
            % Here's a formal description of function usage encoding for the generic function F(), where
            % the first 4 lines are the decoded usage string equivalent and the 5th line with ===> is
            % the encoded string:
            %
            % [r11,...,r1N] = F(a11,...,a1M,p1,...,pL)
            % p1: [v11, ..., v1S1]
            %  ...
            % pL: [vL1, ..., vLSL]
            % ===> F [r11,...,r1N] (a11,...,a1M p1 <v11_form>_..._<v1S1_form> v11_..._v1S1 ... pL <vL1_form>_..._<vLSL_form> vL1_..._vLSL
            %
            %        -- OR --
            %
            % [r11,...,r1N] = F(a11,...,a1M,p1,...,pL)
            % p1: [v11, ..., v1S1]
            %  ...
            % pj: [vj1, ..., vjSj], maxnum: Sj+k
            %  ...
            % pL: [vL1, ..., vLSL]
            % ===> F [r11,...,r1N] (a11,...,a1M p1 <v11_form>_..._<v1S1_form> v11_..._v1S1 pj <vj1_form>_..._<vjSj+k_form> vj1_..._vjSj ... pL <vL1_form>_..._<vLSL_form> vL1_..._vLSL
            %
            %
            % Here are some concrete examples of the above encoding being applied to Homer3 user functions
            % hmrR_BandpassFilt, hmrR_PruneChannels and hmrR_BlockAvg
            %
            % dod = hmrR_BandpassFilt( dod, t, hpf, lpf )
            % hpf: [0.020]
            % lpf: [0.500]
            % ===> hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.02 lpf %0.3f 0.5
            %
            % SD = hmrR_PruneChannels(d,SD,tInc,dRange,SNRthresh,SDrange,reset)
            % dRange: [1e4, 1e7]
            % SNRthresh: 2
            % SDrange: [0, 45]
            % reset: 0
            % ===> hmrR_PruneChannels SD (d,SD,tIncMan dRange %.0e_%.0e 1e4_1e7 SNRthresh %d 2 SDrange %d_%d 0_45 reset %d 0
            %
            % [dcAvg, dcAvgStd, tHRF, nTrials, dcSum2] = hmrR_BlockAvg( dc, s, t, trange )
            % trange: [-2.10, 20.30]
            % ===> hmrR_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,dcSum2] (dc,s,t trange %0.2f_%0.2f -2.10_20.30
            %
            %
            %
            % Here's an example illustrating use of maxnum (or maxsize) in parameter descritions
            %
            % [r1, r2, r3] = hmrR_<Example>(a1, a2, a3, p1, p2, p3, p4)
            % p1: [-2.0, 20.0]
            % p2: 1
            % p3: [1,1], maxnum: 4
            % p4: 0.0
            % ===> hmrR_<Example> [r1,r2,r3] (a1,a2,a3 p1 %0.1f_%0.1f -2.0_20.0 p2 %d 1 p3 %d_%d_%d_%d 1_1 p4 %0.1f 0.0
            %
            %
            for ii=1:size(obj.usageoptions,1)
                usage = obj.usageoptions{ii,2};
                
                % F
                encoding = sprintf('%s ', obj.name);
                
                % [r11,...,r1N]
                iequals = find(usage == '=');
                if isempty(iequals)
                    continue;
                end
                argout = usage(1:iequals-1);
                argout(argout==' ')='';
                encoding = sprintf('%s%s ', encoding, argout);
                
                % (a11,...,a1M
                iparenopen = find(usage == '(');
                iparenclose = find(usage == ')');
                if isempty(iparenopen)
                    continue;
                end
                if isempty(iparenclose)
                    continue;
                end
                argin = usage(iparenopen:iparenclose-1);
                argin(argin==' ')='';
                if ~isempty(obj.params)
                    k = strfind(argin, obj.params{1,1});
                    argin = argin(1:k-1);
                    if ~isempty(argin) && ~isalnum(argin(end))
                        argin(end)='';
                    end
                end
                encoding = sprintf('%s%s ', encoding, argin);
                
                % p1 <v11_form>_..._<v1S_form> v11 ... v1S ... pL <vL1_form>_..._<vLS_form> vL1 ... vLS
                p='';
                for jj=1:size(obj.params,1)
                    p = sprintf('%s%s %s %s ',p, obj.params{jj,1}, obj.EncodeParamFormat(jj), obj.EncodeParamVals(jj));
                end
                encoding = strtrim(sprintf('@ %s%s ', encoding, p));
                
                % Add encoded function call string to usage options
                obj.usageoptions{ii,3} = encoding;
                
                % Add a FuncCallClass object that is the parsed equivalent of the
                % encoded function string in obj.usageoptions{ii,3}. This will allow
                % easy lookup and comparison matching in the registry of proc stream
                % FuncCallClass objects.
                obj.usageoptions{ii,4} = FuncCallClass(encoding, obj.usageoptions{ii,1});
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fmt = EncodeParamFormat(obj, idx)
            fmt = '';
            paramstr = obj.params{idx,2};
            scalars = obj.IsolateScalars(paramstr);
            for ii=1:length(scalars)
                fmt = sprintf('%s%s_', fmt, obj.GetFormatScalar(scalars{ii}));
            end
            maxnum = obj.GetNumScalars(paramstr);
            for ii=1:maxnum-length(scalars)
                fmt = sprintf('%s%s_', fmt, obj.GetFormatScalar(scalars{end}));
            end
            if fmt(end)=='_'
                fmt(end)='';
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function vals = EncodeParamVals(obj, idx)
            s = obj.params{idx,2};
            c = obj.IsolateScalars(s);
            vals = cell2str(c);
            vals(vals==' ') = '_';
        end
        
        
        % ----------------------------------------------------------------------------------
        function scalars = IsolateScalars(obj, paramstr)
            paramstr(paramstr=='[') = '';
            k = find(paramstr==']');
            paramstr(k:end) = '';
            scalars = str2cell(paramstr, {':',' ',','});
        end
        
        
        % ----------------------------------------------------------------------------------
        function maxnum = GetNumScalars(obj, s)
            % Example usage standalone:
            % Create empty registry entry to make this function avalable at the matlab prompt.
            % Give it some data to parse out max number of scalar places
            %
            %   fregentry = FuncRegEntryClass();
            %   fregentry.GetNumScalars('[1,1,5.0]')
            %   fregentry.GetNumScalars('[6.0,1,7], 4')
            %
            scalars = obj.IsolateScalars(s);
            maxnum = length(scalars);
            i = find(s=='[');
            j = find(s==']');
            if isempty(i) || isempty(j)
                return;
            else
                if isempty(s(j+1:end))
                    return;
                else
                    % Check for keywords maxnum and maxsize to see if there information about the maximum
                    % number of values allowed for this parameter. Basically it is a check of the characters
                    % between end of the param list and end-of-the-line; it should be one of the following:
                    %
                    %  case a) ' maxnum: <n>'
                    %  case b) ' maxsize: <n>'
                    %  case c) ', <n>'
                    %  case d) '; <n>'
                    %  case e) ' <n>'
                    
                    k1 = strfind(s, 'maxnum');
                    k2 = strfind(s, 'maxsize');
                    
                    % case a)
                    if ~isempty(k1)
                        maxnumstr = s(k1+length('maxnum')+1:end);
                        if isempty(maxnumstr)
                            return;
                        end
                        
                        % case b)
                    elseif ~isempty(k2)
                        maxnumstr = s(k2+length('maxsize')+1:end);
                        if isempty(maxnumstr)
                            return;
                        end
                        
                        % cases c), d), e)
                    else
                        s2 = s(j+1:end);
                        s2(s2==',' | s2==';') = '';
                        if ~isnumber(s2)
                            return;
                        end
                        maxnumstr = s2;
                    end
                    
                    % Check the resulting number, make sure it's not empty and a positive integer
                    if isempty(maxnumstr)
                        return;
                    end
                    n = str2num(maxnumstr);
                    if ~iswholenum(n) && n>0
                        return;
                    end
                    maxnum = str2num(maxnumstr);
                    
                    % Check to make sure the max number of scalrs after the param values list is smaller
                    % than length of the param value list. If it is smaller then save the user from themselves
                    % and assume they forgot to update that maxnum in the help.
                    if maxnum<length(scalars)
                        maxnum = length(scalars);
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fmt = GetFormatScalar(obj, s)
            k1 = find(s=='.');
            k2 = find(s=='e');
            if ~isempty(k2)
                m = length(s(k1+1:k2-1));
                fmt = sprintf('%%0.%de', m);                
            elseif ~isempty(k1)
                m = length(s(k1+1:end));
                fmt = sprintf('%%0.%df', m);
            else
                fmt = '%d';
            end
        end
        
        
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get methods to retrieve various usage info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function helpstr = GetHelpStr(obj)
            helpstr = obj.help.GetStr();
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = GetUsageStr(obj, idx)
            %
            % Syntax:
            %    str = GetUsageStr(obj, idx)
            %
            % Example:
            %    fregentry = FuncRegEntryClass('hmrR_BlockAvg');
            %    fregentry.GetUsageStr('dcAvg')
            %
            %      ans =
            %
            %      hmrR_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,dcSum2] (dc,s,t trange %0.1f_%0.1f -2.0_20.0
            %
            str = '';
            if ~exist('idx','var') || isempty(idx)
                idx = 1;
            elseif ischar(idx)
                usagename = idx;
                if isempty(usagename)
                    idx = 1;
                else
                    for ii=1:size(obj.usageoptions,1)
                        
                        % First see if usage name matches
                        if strcmp(obj.usageoptions{ii,1}, usagename)
                            idx = ii;
                            break;
                            % Second see if usage name matches any of the input
                            % or output arguments
                        elseif ~isempty(strfind(obj.usageoptions{ii,3}, usagename))
                            idx = ii;
                            break;
                        end
                    end
                end
            end
            if isempty(idx)
                return;
            end
            if idx>size(obj.usageoptions,1)
                return;
            end
            if idx<1
                return;
            end
            if ~iswholenum(idx)
                return;
            end
            str = obj.usageoptions{idx,3};
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = GetUsageStrDecorated(obj, idx)
            str='';
            if ~exist('idx','var') || isempty(idx)
                idx = 1;
            end
            tempstr = obj.GetUsageStr(idx);
            if isempty(tempstr)
                return;
            end
            str = sprintf('%s', tempstr);
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = GetName(obj)
            str = obj.name;
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = GetUiname(obj)
            str = obj.uiname;
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetOptionsNum(obj)
            n = size(obj.usageoptions,1);
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcallstr = GetFuncCallStrDecoded(obj, usagename)
            fcallstr = '';
            if nargin<2
                return;
            end
            if isempty(usagename)
                return;
            end            
            for ii=1:size(obj.usageoptions,1)
                if strcmp(obj.usageoptions{ii,1}, usagename)
                    fcallstr = obj.usageoptions{ii,2};
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcall = GetFuncCallDecoded(obj, usagename)
            fcall = FuncCallClass().empty();
            for ii=1:size(obj.usageoptions,1)
                if strcmp(obj.usageoptions{ii,1}, usagename)
                    fcall = obj.usageoptions{ii,4};
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcall = FindClosestMatch(obj, fcall0)
            fcall = FuncCallClass().empty();
            maxscore = 0;
            imaxscore = [];
            for ii = 1:size(obj.usageoptions,1)
                currscore = fcall0.Compare(obj.usageoptions{ii,4});
                if  currscore > maxscore && currscore > 50
                    maxscore = currscore;
                    imaxscore = ii;
                end
            end
            if ~isempty(imaxscore)
                fcall = FuncCallClass(obj.usageoptions{imaxscore,4});
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function paramtxt = GetParamText(obj)
            paramtxt = '';
            for ii=1:size(obj.params,1)
                paramtxt = sprintf('%s%s: %s\n', paramtxt, obj.params{ii,1}, obj.params{ii,2});
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function usagename = GetUsageName(obj, fcall)
            usagename = '';
            if ~isa(fcall,'FuncCallClass')
                return
            end
            for jj=1:size(obj.usageoptions,1)
                if fcall == obj.usageoptions{jj,4}
                    usagename = obj.usageoptions{jj,1};
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function usagenames = GetUsageNames(obj)
            usagenames = cell(size(obj.usageoptions,1));
            for jj=1:size(obj.usageoptions,1)
                usagenames{jj} = obj.usageoptions{jj,1};
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetNumUsages(obj)
            n = length(obj.GetUsageNames(obj));
        end
        
        
        % ----------------------------------------------------------------------------------
        function fcallstr = GetFuncCallsEncoded(obj, fcall)
            fcallstr = '';
            for jj=1:size(obj.usageoptions,1)
                if fcall == obj.usageoptions{jj,4}
                    fcallstr = obj.usageoptions{jj,3};
                    break;
                end
            end
        end
        
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            obj.name = obj2.name;
            obj.uiname = obj2.uiname;
            for ii=1:size(obj2.usageoptions,1)
                for jj=1:size(obj2.usageoptions,2)
                    if isa(obj2.usageoptions{ii,jj}, 'FuncCallClass')
                        obj.usageoptions{ii,jj} = FuncCallClass(obj2.usageoptions{ii,jj});
                    else
                        obj.usageoptions{ii,jj} = obj2.usageoptions{ii,jj};
                    end
                end
            end
            obj.params = obj2.params;
            obj.help = obj2.help.copy();
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsValid(obj)
            b = false;
            if isempty(obj)
                return;
            end
            if isempty(obj.name)
                fprintf('Function name not valid.\n')
                return
            end
            if isempty(obj.uiname)
                fprintf('UI NAME section not valid.\n')
                return
            end
            if isempty(obj.usageoptions)
                fprintf('USAGE OPTIONS section not valid.\n')
                return
            end
            if isempty(obj.help)
                fprintf('Function help section not valid.\n')
                return
            end
            b = true;
        end
        
    end
    
    
end
