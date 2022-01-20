classdef FuncCallClass < handle
    properties
        name
        nameUI
        argOut
        argIn
        paramIn
        help
        encodedStr
        err
    end
    
    methods
        
        % ------------------------------------------------------------
        function obj = FuncCallClass(varargin)
            %
            % Syntax:
            %   obj = FuncCallClass()
            %   obj = FuncCallClass(fcallStrEncoded)
            %   obj = FuncCallClass(fcallStrEncoded, reg)
            %
            % Example:
            %
            %   fcall = FuncCallClass('@ hmrBandpassFilt dod (dod,t hpf %0.3f 0.01 lpf %0.2f 0.5')
            %
            %       ===> FuncCallClass with properties:
            %
            %             name: 'hmrBandpassFilt'
            %           nameUI: 'hmrBandpassFilt'
            %        argOut.str: 'dod'
            %         argIn.str: '(dod,t'
            %          paramIn: [1x2 ParamClass]
            %             help: '  Perform a bandpass filter…'
            %
            obj.name       = '';
            obj.nameUI     = '';
            obj.argOut     = ArgClass().empty;
            obj.argIn      = ArgClass().empty;
            obj.paramIn    = ParamClass().empty;
            obj.help       = '';
            obj.encodedStr = '';
            obj.err        = 0; 
            if nargin==0
                return;
            end
            
            if ischar(varargin{1}) || iscell(varargin{1})
                obj.Decode(varargin{1});
            elseif isa(varargin{1}, 'FuncCallClass')
                obj.Copy(varargin{1});
            end
            
            if nargin==1
                return;
            end
            obj.AddUsageInfo(varargin{2});
            
        end

        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, reg)
            if isempty(obj)
                obj = FuncCallClass();
            end
            if nargin<3
                reg = RegistriesClass.empty();
            end
            obj.name = obj2.name;
            obj.nameUI = obj2.nameUI;
            obj.argOut = obj2.argOut.copy();     % shallow copy ok because ArgClass has no handle properties 
            obj.argIn = obj2.argIn.copy();       % shallow copy ok because ArgClass has no handle properties 
            for ii=1:length(obj2.paramIn)
                obj.paramIn(ii) = obj2.paramIn(ii).copy();   % shallow copy ok because ParamClass has no handle properties 
            end
            obj.help = obj2.help;
            obj.encodedStr = obj2.encodedStr;
            obj.AddUsageInfo(reg);
        end
        
        
        % ------------------------------------------------------------
        function helpstr = GetHelp(obj)
            if isempty(obj.help)
                fhelp = FuncHelpClass(obj.name);
                obj.help = fhelp.GetDescr();
            end
            helpstr = obj.help;
        end
        
        
        
        % ------------------------------------------------------------
        function name = GetName(obj)
            name = obj.name;
        end
        
        
        % ------------------------------------------------------------
        function name = GetUsageName(obj)
            name = obj.nameUI;
        end
               
        
        % ------------------------------------------------------------
        function idx = GetParamIdx(obj, key)
            idx = [];
            if ~exist('key','var') || isempty(key)
                key=1;
            end
            if ischar(key)
                for ii=1:length(obj.paramIn)
                    if strcmp(key, obj.paramIn(ii).name)
                        idx=ii;
                        break;
                    end
                end
            elseif iswholenum(key) && (key <= length(obj.paramIn))
                idx = key;
            end
        end
        
        
        % ------------------------------------------------------------
        function phelp = GetParamHelp(obj, key)
            phelp = '';
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            if isempty(obj.paramIn(idx).help)
                fhelp = FuncHelpClass(obj.name);
                obj.paramIn(idx).help = fhelp.GetParamDescr(obj.paramIn(idx).name);
            end
            phelp = obj.paramIn(idx).help;
        end
        
        
        % ------------------------------------------------------------
        function fmt = GetParamFormat(obj, key)
            fmt = '';
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            fmt = obj.paramIn(idx).format;
        end
        
        
        % ------------------------------------------------------------
        function val = GetParamVal(obj, key)
            val = '';
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            val = obj.paramIn(idx).value;
        end
        
        
        
        % ------------------------------------------------------------
        function valstr = GetParamValStr(obj, key)
            valstr = '';
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            valstr = sprintf(obj.paramIn(idx).format, obj.paramIn(idx).value);
        end
        
        
        
        % ------------------------------------------------------------
        function inputs = GetInputs(obj)
           inputs = obj.argIn.Extract(); 
        end
        
        
        
        % ------------------------------------------------------------
        function outputs = GetOutputs(obj)
           outputs = obj.argOut.Extract(); 
        end
            
        
        
        % ----------------------------------------------------------------------------------
        function SetUsageName(obj, usagename)
            if nargin<2
                usagename='';
            end
            
            % If usage name is already set, then we're done
            k = find((obj.nameUI==':')==1);
            if ~isempty(k)
                if (k(1) > 1) && (k(1) < length(obj.nameUI))  && isempty(usagename)
                	return;
            	end
            end
            if isempty(usagename)
                obj.nameUI = obj.name;
            else
                obj.nameUI = [obj.name, ':  ', usagename];
            end
        end

        
        % ----------------------------------------------------------------------------------
        function DecodeArgIn(obj)
            if isempty(obj.argIn.str)
                return                
            end
            s = strtrim(obj.argIn.str);
            if s(1)~='('
                return;              
            end
            args = str2cell_fast(s(2:end),',');
            fhelp = FuncHelpClass(obj.name);
            for ii=1:length(args)
                obj.argIn.vars(ii).name = args{ii};
                obj.argIn.vars(ii).help = fhelp.GetParamDescr(ii);
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Decode(obj, fcallStrEncoded)
            %
            % Syntax:
            %   obj = Decode(fcallStrEncoded)
            %
            % Example:
            %
            %   fcall = FuncCallClass()
            %   fcall.Decode('@ hmrBandpassFilt dod (dod,t hpf %0.3f 0.01 lpf %0.2f 0.5')
            %
            %       ===> FuncCallClass with properties:
            %
            %          name: 'hmrBandpassFilt'
            %        nameUI: 'hmrBandpassFilt'
            %        argOut: 'dod'
            %         argIn.str: '(dod,t'
            %       paramIn: [1x2 ParamClass]
            %          help: '  Perform a bandpass filter…'
            %   
            obj.err = 0;            
            if nargin<2
                obj.err=-1;
                return;
            end
            if isempty(fcallStrEncoded)
                obj.err=-1;
                return;
            end
            if ~ischar(fcallStrEncoded)
                obj.err=-1;
                return;
            end
            obj.encodedStr = fcallStrEncoded;
            
            C = textscan(fcallStrEncoded, '%s');
            if C{1}{1}(1)~='@'
                textstr = [{'@'}; C{1}];
            else
                textstr = C{1};
            end
            nstr = length(textstr);
            flag = 0;
            for ii=1:nstr
                if flag==0 || textstr{ii}(1)=='@'
                    if textstr{ii}=='%'
                        flag = 999;
                    elseif textstr{ii}=='@'
                        k = strfind(textstr{ii+1},',');
                        if ~isempty(k)
                            obj.name   = textstr{ii+1}(1:k-1);
                            obj.nameUI = textstr{ii+1}(k+1:end);
                            k = strfind(obj.nameUI,'_');
                            obj.nameUI(k)=' ';
                        else
                            obj.name = textstr{ii+1};
                            obj.nameUI = obj.name;
                        end
                        obj.GetHelp();
                        if isempty(obj.argOut)
                            obj.argOut = ArgClass();
                        end
                        if isempty(obj.argIn)
                            obj.argIn = ArgClass();
                        end
                        if length(textstr)<(ii+2)
                            continue
                        end
                        obj.argOut.str = textstr{ii+2};
                        if length(textstr)<(ii+3)
                            continue
                        end
                        obj.argIn.str = textstr{ii+3};
                        obj.DecodeArgIn();
                        flag = 3;
                    else
                        % If function call string continues, means we have
                        % user-settable params, since params follow input
                        % arguments
                        pname = textstr{ii};
                        if ~isalnum(pname(1))
                            obj.err=-1;
                            return;
                        end
                        if ii+1>length(textstr)
                            obj.err=-1;
                            return;
                        end
                        for jj = 1:length(textstr{ii+1})
                            if textstr{ii+1}(jj)=='_'
                                textstr{ii+1}(jj) = ' ';
                            end
                        end
                        if length(textstr)<(ii+2)
                            continue
                        end
                        pformat = textstr{ii+1};
                        for jj = 1:length(textstr{ii+2})
                            if textstr{ii+2}(jj)=='_'
                                textstr{ii+2}(jj) = ' ';
                            end
                        end
                        pvalue = str2num(textstr{ii+2});                       
                        % Save default values in ParamClass
                        obj.paramIn(end+1) = ParamClass(pname, pformat, pvalue, pvalue);
                        obj.GetParamHelp(length(obj.paramIn));
                        flag = 2;
                    end
                else
                    flag = flag-1;
                end
            end
        end
        
        

        % ----------------------------------------------------------------------------------
        function fcallStrEncoded = Encode(obj)
            %
            % Syntax:
            %   fcallStrEncoded = obj.Encode()
            %
            % Example:
            %
            %   fcall = FuncCallClass()
            %   fcall.Decode('@ hmrBandpassFilt dod (dod,t hpf %0.3f 0.01 lpf %0.2f 0.5')
            %   s = fcall.Encode()
            %   
            %         '@ hmrBandpassFilt dod (dod,t hpf %0.3f 0.01 lpf %0.2f 0.5'
            %
                                    
            % Encode params str
            paramInStr = '';
            for ii=1:length(obj.paramIn)
                if ii<length(obj.paramIn)
                    space = ' ';
                else
                    space = '';
                end
                if isempty(paramInStr)
                    paramInStr = sprintf('%s%s', obj.paramIn(ii).Encode(), space);
                else
                    paramInStr = sprintf('%s%s%s', paramInStr, obj.paramIn(ii).Encode(), space);
                end
            end
                        
            obj.encodedStr = sprintf('@ %s %s %s %s', obj.name, obj.argOut.Encode(), obj.argIn.Encode(), paramInStr);
                
            fcallStrEncoded = obj.encodedStr;
        end
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Comparison methods and overriden operators
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        % Override == operator: 
        % ----------------------------------------------------------------------------------
        function B = eq(obj, obj2)
            B = 0;            
            if isa(obj2, 'FuncCallClass')
                if ~strcmp(obj.name, obj2.name)
                    return;
                end
                if ~strcmp(obj.argOut.str, obj2.argOut.str)
                    return;
                end
                if ~strcmp(obj.argIn.str, obj2.argIn.str)
                    return;
                end
                if length(obj.paramIn) ~= length(obj2.paramIn)
                    return;
                end
%               Must have the same number of params, but their individual
%               lengths can differ

            elseif isstruct(obj2)
                % Name 
                k = find(obj.name=='_');
                s1 = obj.name;
                s2 = obj2.funcName;
                if length(k)==1
                    s1 = obj.name(k(1)+1:end);
                elseif length(k)>1
                    s1 = obj.name(k(1)+1:k(end)-1);
                end
                if ~includes(s2,s1)
                    % if func names differ check if the user friendly names
                    % are similar...
                    if ~includes(obj2.funcNameUI, obj.nameUI)
                        if ~includes(obj.nameUI, obj2.funcNameUI)
                            return;
                        end
                    end
                end
                               
                % We don't necessarily have to have the same number of
                % params to be equal as long as all the params in obj
                % exist in obj2 in the same order. 
                eq = 0;
                for ii=1:length(obj.paramIn)
                    for jj=1:length(obj2.funcParam)
                        paramIn2.name = obj2.funcParam{jj};
                        paramIn2.format = obj2.funcParamFormat{jj};
                        paramIn2.value = obj2.funcParamVal{jj};
                        eq = obj.paramIn(ii) == paramIn2;
                        if eq==1
                            break;
                        end
                        continue;
                    end
                    if eq~=1
                        B = eq;
                        return;
                    end
                end
            end
            B = 1;
        end

               
        % ----------------------------------------------------------------------------------
        % Override ~= operator: 
        % ----------------------------------------------------------------------------------
        function B = ne(obj, obj2)
            r = obj == obj2;
            if r ~= 1
                B = 1;
            else
                B = 0;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function scorefinal = Compare(obj, obj2)           
            score = [];
            if strcmp(obj.name, obj2.name)
                score(end+1) = 0.50;
            elseif ~isempty(findstr(obj.name, obj2.name))
                score(end+1) = 0.30;
            else
                score(end+1) = 0;
            end
            score(end+1) = 0.16 * obj.argOut.Compare(obj2.argOut);
            score(end+1) = 0.16 * obj.argIn.Compare(obj2.argIn);
            
            % For parameters first get separate score then add to total 
            scoreParams = zeros(1,max([length(obj.paramIn), length(obj2.paramIn)]));
            
            for ii = 1:length(obj.paramIn)
                for jj = 1:length(obj2.paramIn)
                    if strcmp(obj.paramIn(ii).GetName(), obj2.paramIn(jj).GetName())
                        scoreParams(ii) = obj.paramIn(ii).Compare(obj2.paramIn(jj));
                        if ii ~= jj
                            scoreParams(ii) = .75 * scoreParams(ii);
                        end
                    end
                end
            end
            
            % Tally up final results
            score = [score(:)', 0.18 * mean(scoreParams(:))']; 
            scorefinal = 100*sum(score);
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function val = GetErr(obj)
            val = obj.err;
        end
                       
        
        % -----------------------------------------------------------------
        function maxnamelen = GetMaxParamNameLength(obj)
            maxnamelen = 0;
            for iParam = 1:length(obj.paramIn)
                if length(obj.paramIn(iParam).name) > maxnamelen
                    maxnamelen = length(obj.paramIn(iParam).name)+1;
                end
            end
        end
        
        
        % -----------------------------------------------------------------
        function AddHelpUsageStr(obj, fcallstr)
            if isempty(obj)
                return;
            end
            if nargin<2
                return;
            end
            if isempty(fcallstr)
                return;
            end
            n = length(fcallstr);
            
            % Check to make sure we haven't already added the usage function call as may 
            % happend when selecting wrong config file
            if strncmp(fcallstr, obj.help, n)
                return;
            end
            sep = repmat('-', 1,n);
            obj.help = sprintf('%s\n%s\n%s', fcallstr, sep, obj.help);
        end
        
        
        
        % -----------------------------------------------------------------
        function n = GetParamNum(obj)
            n = length(obj.paramIn);
        end
        

        % -----------------------------------------------------------------
        function name = GetParamName(obj, idx)
            name = '';
            if nargin<2
                return;
            end
            if ~iswholenum(idx)
                return;
            end
            if ~isscalar(idx)
                return;
            end
            if idx<1 || idx>length(obj.paramIn)
                return;
            end
            name = obj.paramIn(idx).GetName();            
        end
       
        
        % -----------------------------------------------------------------
        function AddUsageInfo(obj, arg)
            if nargin<2
                return;
            end
            if isa(arg, 'RegistriesClass')
                reg = arg;
                
                usagename = reg.GetUsageName(obj);
                fcallstr = reg.GetFuncCallStrDecoded(obj.name, usagename);
                obj.AddHelpUsageStr(fcallstr);
                
                if length(reg.GetUsageNames(obj.name))<2
                    usagename = '';
                end
            elseif ischar(arg)
                usagename = arg;
            end
            obj.SetUsageName(usagename);
        end
        
        
        
        % ----------------------------------------------------------------------------------        
        function nbytes = MemoryRequired(obj)            
            fields = properties(obj);
            nbytes = zeros(length(fields),1);
            if isempty(obj)
                nbytes = 0;
                return
            end
            for ii = 1:length(fields)
                fieldstr = sprintf('obj.%s', fields{ii});
                if ~eval('isempty(fieldstr)')
                    nbytes(ii) =  eval(sprintf('sizeof(%s);', fieldstr));
                end
            end
            nbytes = sum(nbytes);
        end



        % ----------------------------------------------------------------------------------        
        function errmsg = CheckParams(obj)
            errmsg = '';
            paramValStr = '';
            if exist([obj.name, '_errchk'], 'file')  % If errchk fn is on path
                for i = 1:length(obj.paramIn)  % Assemble list of args
                   paramValStr = [paramValStr, obj.paramIn(i).GetFormattedValue()]; %#ok<AGROW>
                   if i < length(obj.paramIn)
                       paramValStr = [paramValStr, ',']; %#ok<AGROW>
                   end
                end
                % Call the errchk function which returns a non-empty string
                % if there is an error
                eval(['errmsg = ', obj.name, '_errchk(', paramValStr, ')']);
                if ~isempty(errmsg)
                   errmsg = [obj.name, ': ', errmsg];
                end
            else
               return;
            end
        end
        


        % ----------------------------------------------------------------------------------        
        function val = GetVar(obj, name)
            val = [];
            if isempty(obj)
                return;
            end
            for ii = 1:length(obj.paramIn)
                if strcmp(name, obj.paramIn(ii).GetName())
                    val = obj.paramIn(ii).GetValue();
                    break;
                end
            end
        end
        
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
    end
end

