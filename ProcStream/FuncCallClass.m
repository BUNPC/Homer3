classdef FuncCallClass < handle
    properties
        name
        nameUI
        argOut
        argIn
        paramIn
        help
    end
    
    methods
        
        % ------------------------------------------------------------
        function obj = FuncCallClass(fcallEncodedStr)
            obj.name        = '';
            obj.nameUI      = '';
            obj.argOut      = '';
            obj.argIn       = '';
            obj.paramIn     = ParamClass().empty;
            obj.help        = '';
            
            if nargin==0
                return;
            end            
            obj.Parse(fcallEncodedStr);
            
        end

        
        % ------------------------------------------------------------
        function obj = GetHelp(obj)
            fhelp = FuncHelpClass(obj.name);
            obj.help = fhelp.GetDescr();
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
        function Parse(obj, fcallEncodedStr)
            %
            % Syntax:
            %   obj = Parse()
            %   obj = Parse(fcallEncodedStr)
            %
            % Example:
            %
            %   fcall = FuncCallClass('@ hmrBandpassFilt dod (dod,t hpf %0.3f 0.01 lpf %0.2f 0.5')
            %
            %       ===> FuncCallClass with properties:
            %
            %          name: 'hmrBandpassFilt'
            %        nameUI: 'hmrBandpassFilt'
            %        argOut: 'dod'
            %         argIn: '(dod,t'
            %       paramIn: [1x2 ParamClass]
            %          help: '  Perform a bandpass filter…'
            %
            if nargin<2
                return;
            end
            if isempty(fcallEncodedStr)
                return;
            end
            if ~ischar(fcallEncodedStr)
                return;
            end
            
            C = textscan(fcallEncodedStr, '%s');
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
                            obj.name = textstr{ii+1}(1:k-1);
                            obj.nameUI = textstr{ii+1}(k+1:end);
                            k = strfind(obj.nameUI,'_');
                            obj.nameUI(k)=' ';
                        else
                            obj.name = textstr{ii+1};
                            obj.nameUI = obj.name;
                        end
                        obj.argOut = textstr{ii+2};
                        obj.argIn = textstr{ii+3};
                        obj.GetHelp();
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

