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
            %             help: '  Perform a bandpass filter�'
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
            
            reg = varargin{2};            
            obj.AddUsageInfo(reg);
            
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
        function name = GetNameUserFriendly(obj)
            name = obj.nameUI;
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
        
        
        
        % ----------------------------------------------------------------------------------
        function SetUsageName(obj, usagename)
            if nargin<2
                usagename='';
            end
            
            % If usage name is already set, then we're done
            c = str2cell(obj.nameUI, ':');
            if length(c)==2 && isempty(usagename)
                return;
            end
            if isempty(usagename)
                obj.nameUI = sprintf('%s', obj.name);
            else
                obj.nameUI = sprintf('%s:  %s', obj.name, usagename);
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
            args = str2cell(s(2:end),',');
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
            %          help: '  Perform a bandpass filter�'
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
                        obj.argOut.str = textstr{ii+2};
                        obj.argIn.str = textstr{ii+3};
                        obj.DecodeArgIn();
                        flag = 3;
                    else
                        % If function call string continues, means we have
                        % user-settable params, since params follow input
                        % arguments
                        pname = textstr{ii};
                        if ~isalpha_num(pname(1))
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
                        pformat = textstr{ii+1};
                        for jj = 1:length(textstr{ii+2})
                            if textstr{ii+2}(jj)=='_'
                                textstr{ii+2}(jj) = ' ';
                            end
                        end
                        pvalue = str2num(textstr{ii+2});                       
                        obj.paramIn(end+1) = ParamClass(pname, pformat, pvalue);
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
            fcallStrEncoded = obj.encodedStr;
        end
        
                
        % ----------------------------------------------------------------------------------
        % Override == operator: 
        % ----------------------------------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
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
            for ii=1:length(obj.paramIn)
                if obj.paramIn(ii) ~= obj2.paramIn(ii)
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
        function AddUsageInfo(obj, reg)
            if nargin<2
                return;
            end
            usagename = reg.GetUsageName(obj);
            fcallstr = reg.GetFuncCallStrDecoded(obj.name, usagename);
            obj.AddHelpUsageStr(fcallstr);            
            
            if length(reg.GetUsageNames(obj.name))<2
                usagename = '';
            end
            obj.SetUsageName(usagename);
        end
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
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
        
        
    end
end

