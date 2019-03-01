classdef FuncCallClass < handle
    properties
        name
        nameUI
        argOut
        argIn
        paramIn
        help
        encodedStr
    end
    
    methods
        
        % ------------------------------------------------------------
        function obj = FuncCallClass(arg)
            %
            % Syntax:
            %   obj = FuncCallClass()
            %   obj = FuncCallClass(fcallStrEncoded)
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
            
            if nargin==0
                return;
            end
            
            if ischar(arg) || iscell(arg)
                obj.Decode(arg);
            elseif isa(arg, 'FuncCallClass')
                obj.Copy(arg);
            end
        end

        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isempty(obj)
                obj = FuncCallClass();
            end
            obj.name = obj2.name;
            obj.nameUI = obj2.name;
            obj.argOut = obj2.argOut.copy();     % shallow copy ok because ArgClass has no handle properties 
            obj.argIn = obj2.argIn.copy();       % shallow copy ok because ArgClass has no handle properties 
            for ii=1:length(obj2.paramIn)
                obj.paramIn(ii) = obj2.paramIn(ii).copy();   % shallow copy ok because ParamClass has no handle properties 
            end
            obj.help = obj2.help;
            obj.encodedStr = obj2.encodedStr;
        end
        
        
        % ------------------------------------------------------------
        function GetHelp(obj)
            fhelp = FuncHelpClass(obj.name);
            obj.help = fhelp.GetDescr();
        end
        
        
        % ------------------------------------------------------------
        function name = GetName(obj)
            name = obj.name;
        end
        
        
        
        % ------------------------------------------------------------
        function GetParamHelp(obj, key)
            if isempty(obj.paramIn)
                return
            end
            idx = obj.GetParamIdx(key);
            if isempty(idx)
                return;
            end
            fhelp = FuncHelpClass(obj.name);
            obj.paramIn(idx).help = fhelp.GetParamDescr(obj.paramIn(idx).name);
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
            %          help: '  Perform a bandpass filter…'
            %
            if nargin<2
                return;
            end
            if isempty(fcallStrEncoded)
                return;
            end
            if ~ischar(fcallStrEncoded)
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
                        % If function call string continue, means we have
                        % user-settable params, since params follow input
                        % arguments
                        pname = textstr{ii};
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
            if ~strcmp(obj.nameUI, obj2.nameUI)
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

