classdef FuncHelpClass < matlab.mixin.Copyable
    
    properties
        funcname;
        helpstr;
        sections;
        userfuncdir;
        config;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Initialization methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -------------------------------------------------------------
        function obj = FuncHelpClass(funcname)
            % Syntax:
            %       fhelp = FuncHelpClass(funcname);
            %
            % Examples:
            %       fhelp = FuncHelpClass('hmrR_DeconvHRF_DriftSS');
            %
            obj.userfuncdir = {};
            obj.config = [];
            
            if nargin==0
                return;
            end
            obj.funcname = funcname;
            if isdeployed()
                obj.userfuncdir = obj.UserFuncDirs(obj);
            end
            obj.Help();
            obj.ParseSections();
            
        end
        
        
        % ---------------------------------------------------------------
        function AddSection(obj, name)
            fieldname = name;
            fieldname(fieldname==' ')='';
            fieldname = lower(fieldname);
            newsection = struct(...
                'name',name, ...
                'lines',[0,0], ...
                'str','', ...
                'subsections', [] ...
                );
            eval( sprintf('obj.sections.%s = newsection;', fieldname) );
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Methods for parsing sections
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -------------------------------------------------------------
        function ParseSections(obj)
            % This method dynamically parses the help section of a matlab function
            % that is in the generic format described below. The format
            % consists of a series of sections and sub-sections like this:
            %
            % ------------------------------------------------------------
            % <SECTION NAME i>:
            % <help text for <SECTION NAME i> spanning one or more lines>
            %
            %       -- OR --
            %
            % <SECTION NAME i>:
            % <sub-section1_i>: <help text for sub-section1_i spanning one or more lines>
            % <sub-section2_i>: <help text for sub-section2_i spanning one or more lines>
            %  . . . . . .
            % <sub-sectionN_i>: <help text for sub-sectionN_i spanning one or more lines>
            %
            % ------------------------------------------------------------
            %
            % For <SECTION NAME i> to be considered a section (as opposed to sub-section)
            % it must be in all uppercase, must be followed by a ':', and must not have
            % any other text on that line. A sub-section is any string without white
            % spaces preceding the first occurrence of ':', ' - ' or '--' on a line line.
            %
            % In addition to the generic parsing of sections, this class also provides
            % methods for accessing specific 'designated' sections should they exist in
            % the help comments. A section is defined as designated in this class if it
            % provides public Get* methods to access it. Current designated sections are
            %
            %       Designated Sections    Associated methods
            %       --------------------------------------
            %       'DESCRIPTION:'          % GetDescr()
            %       'INPUT(S):'             % GetParamDescr()
            %       'USAGE OPTIONS:'        % GetUsageOptions()
            %       'PARAMETERS:'           % GetParamUsage()
            %
            % New methods can be added for any new designated sections added to this
            % class in the future
            %
            % Example from Homer3: formal description of user functions
            % help section syntax:
            % --------------------------------------------------------------
            % SYNTAX:
            % [r1,...,rN] = <funcname>(a1,...,aM,p1,...,pL)
            %
            % UI NAME:
            % <User Interface Function Name>
            %
            % DESCRIPTION:
            % <General function description>
            %
            % INPUT:
            % a1: <Description of a1>
            %    . . . . . . . . . .
            % aM: <Description of am>
            % p1: <Description of am>
            %    . . . . . . . . . .
            % pL: <Description of am>
            %
            % OUPUT:
            % r1: <Description of r1>
            %    . . . . . . . . . .
            % rN: <Description of rN>
            %
            % USAGE OPTIONS:
            % <User-friendly name for option 1>: [r11,...,r1N] = <funcname>(a11,...,a1M,p1,...,pL)
            %    . . . . . . . . . .
            % <User-friendly name for option K>: [rK1,...,rKN] = <funcname>(aK1,...,aKM,p1,...,pL)
            %
            % PARAMETERS:
            % p1: [v11,...,v1J]
            %    . . . . . . . . . .
            % pL: [vL1,...,vLJ]
            %
            if isempty(obj.helpstr)
                return;
            end
            
            sect = obj.FindSections();
            for ii=1:length(sect)
                obj.AddSection(sect{ii});
            end
            
            % Find the lines in the help that belong to each help section
            obj.FindSectionLines();
            
            % Remove leading and trailing blank lines from each section
            obj.RemoveBlankLines();
            
            % Now that we have the lines associated with each help section,
            % assign the text from these lines to corresponding help sections.
            obj.AssignSectionText();
            
            % We have parsed all sections: now parse sub-sections for each
            % section
            sect = propnames(obj.sections);
            for ii=1:length(sect)
                obj.ParseSubSections(sect{ii});
            end
            
        end
        
        
        % -------------------------------------------------------------
        function sect = FindSections(obj)
            kk=1;
            sect = cell(length(obj.helpstr),1);
            for ii=1:length(obj.helpstr)
                if obj.IsSectionName(obj.helpstr{ii})
                    k = find(obj.helpstr{ii}==':');
                    sect{kk,:} = strtrim(obj.helpstr{ii}(1:k-1));
                    kk=kk+1;
                end
            end
            sect(kk:end) = [];
        end
        
        
        % -------------------------------------------------------------
        function FindSectionLines(obj)
            fields = propnames(obj.sections);
            for iLine=1:length(obj.helpstr)
                for jj=1:length(fields)
                    secname = eval( sprintf('obj.sections.%s.name', fields{jj}) );
                    if includes(obj.helpstr{iLine}, secname)
                        EndPrevSection(obj, iLine);
                        eval( sprintf('obj.sections.%s.lines(1) = iLine+1;', fields{jj}) );
                    end
                end
            end
            EndPrevSection(obj, iLine+1);
        end
        
        
        % -------------------------------------------------------------
        function AssignSectionText(obj)
            fields = propnames(obj.sections);
            for jj=1:length(fields)
                lines = eval( sprintf('obj.sections.%s.lines(1):obj.sections.%s.lines(2)', fields{jj}, fields{jj}) );
                for iLine = lines
                    if iLine < 1 || isempty(obj.helpstr{iLine})
                        continue;
                    end
                    eval( sprintf('obj.sections.%s.str = sprintf(''%%s%%s\\n'', obj.sections.%s.str, obj.helpstr{iLine});', ...
                        fields{jj}, fields{jj}) );
                end
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods for accessing designated sections
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -------------------------------------------------------------
        function str = GetUiname(obj)
            str = '';
            if isproperty(obj.sections,'uiname')
                str = strtrim(obj.sections.uiname.str);
            end
        end
        
        
        % -------------------------------------------------------------
        function str = GetDescr(obj)
            str = '';
            if isproperty(obj.sections,'description')
                str = obj.sections.description.str;
            end
        end
        
        
        % -------------------------------------------------------------
        function str = GetParamDescr(obj, param)
            str = '';
            subsections = [];
            if isproperty(obj.sections,'input')
                subsections = obj.sections.input.subsections;
            end
            if isproperty(obj.sections,'inputs')
                subsections = obj.sections.inputs.subsections;
            end
            if isempty(subsections)
                return;
            end
            
            % if the input is a number index into the inputs arrays, then we
            % don't need to seach for the param name
            if iswholenum(param)
                if param <= length(subsections)
                    str = subsections(param).str;
                end
                return;
            end
            
            % Search for the parameter with name <param>
            for ii=1:length(subsections)
                if strcmp(param, subsections(ii).name)
                    str = subsections(ii).str;
                end
            end
        end
        
        
        % -------------------------------------------------------------
        function [usage, friendlyname] = GetUsageOptions(obj)
            usage = {};
            friendlyname = {};
            subsections = [];
            if isproperty(obj.sections,'usageoptions')
                subsections = obj.sections.usageoptions.subsections;
            end
            if isempty(subsections)
                return;
            end
            usage        = cell(length(subsections),1);
            friendlyname = cell(length(subsections),1);
            for ii=1:length(subsections)
                friendlyname{ii}  = strtrim(subsections(ii).name);
                usage{ii}         = strtrim(subsections(ii).str);
            end
        end
        
        
        % -------------------------------------------------------------
        function [paramname, valformat] = GetParamUsage(obj)
            paramname = {};
            valformat = {};
            subsections = [];
            if isproperty(obj.sections,'parameters')
                subsections = obj.sections.parameters.subsections;
            end
            if isempty(subsections)
                return;
            end
            paramname = cell(length(subsections),1);
            valformat = cell(length(subsections),1);
            for ii=1:length(subsections)
                paramname{ii} = strtrim(subsections(ii).name);
                valformat{ii} = strtrim(subsections(ii).str);
            end
        end
        
        
        % -------------------------------------------------------------
        function helpstr = GetStr(obj)
            helpstr = '';
            fields = propnames(obj.sections);
            for ii=1:length(fields)
                name = eval( sprintf('obj.sections.%s.name', fields{ii}) );
                str = eval( sprintf('obj.sections.%s.str', fields{ii}) );
                helpstr = sprintf('%s%s:\n', helpstr, name);
                helpstr = sprintf('%s%s\n', helpstr, str);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Methods for parsing sub-sections
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -------------------------------------------------------------
        function ParseSubSections(obj, section)
            obj.FindSubSectionLines(section);
            obj.AssignSubSectionText(section);
        end
        
        
        % -------------------------------------------------------------
        function FindSubSectionLines(obj, section)
            strs = str2cell_fast(eval(sprintf('obj.sections.%s.str', section)), [], 'keepblanks');
            kk=0;
            subsect = [];
            for iLine=1:length(strs)
                name = obj.GetSubSectionName(section, iLine);
                if ~isempty(name)
                    kk=kk+1;
                    
                    % Create new sub-section
                    subsect(kk).name = strtrim(name);
                    subsect(kk).lines = [0,0];
                    subsect(kk).str = '';
                    
                    % Assign starting line to current subsection
                    subsect(kk).lines(1) = iLine;
                    
                    % See if there's sub-section preceding current one. If
                    % so, end it
                    if kk>1 && subsect(kk-1).lines(2)==0
                        subsect(kk-1).lines(2) = iLine-1;
                    end
                end
            end
            if kk>0
                if subsect(kk).lines(2)==0
                    subsect(kk).lines(2) = iLine;
                end
            end
            eval( sprintf('obj.sections.%s.subsections = subsect;', section) );
        end
        
        
        % -------------------------------------------------------------
        function [name, k] = GetSubSectionName(obj, section, iLine)
            name = '';
            k = [];
            strs = str2cell_fast(eval(sprintf('obj.sections.%s.str', section)), [], 'keepblanks');
            
            % Rule 1: Valid section is must end with a ':',' - ', or '--'
            k1 = find(strs{iLine}==':');
            k2 = strfind(strs{iLine}, ' - ');
            k3 = strfind(strs{iLine}, '--');
            d=1;
            if ~isempty(k1)
                k = k1(1);
            elseif ~isempty(k2)
                k = k2(1)+2; d = 2;
            elseif ~isempty(k3)
                k = k3(1)+1;
            end
            if isempty(k)
                return;
            end
            temp = strtrim(strs{iLine}(1:(k-d)));
            
            %%%% Check to make sure string preceding ':' is a valid section name.
            
            % Rule 2: If string preceding ':' (ie, potential section name) has spaces then it's
            % not a section name.
            if ~isempty(find(temp==' '))
                return;
            end
            
            % Rule 3: If string preceding ':' is indented greater than 2 spaces then it's not
            % a section name.
            indent_size = strfind(strs{iLine}(1:(k-d)), temp)-1;
            if isempty(indent_size) || indent_size > 2
                return;
            end
            
            name = strtrim(strs{iLine}(1:(k-d)));
            k = k(1);
        end
        
        
        % -------------------------------------------------------------
        function AssignSubSectionText(obj, section)
            strs = str2cell_fast(eval(sprintf('obj.sections.%s.str', section)), [], 'keepblanks');
            subsect = eval(sprintf('obj.sections.%s.subsections', section));
            for ii=1:length(subsect)
                lines = subsect(ii).lines(1):subsect(ii).lines(2);
                for iLine = lines
                    % The help part corresponding to the subsection name (eg, SD: or trange:)
                    % starts after the colon (:) or double dash (--)
                    [~, k] = obj.GetSubSectionName(section, iLine);
                    if ~isempty(k)
                        strs{iLine} = strtrim(strs{iLine}(k+1:end));
                    end
                    subsect(ii).str = sprintf('%s%s\n', subsect(ii).str , strs{iLine});
                end
            end
            eval( sprintf('obj.sections.%s.subsections = subsect;', section) );
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
        % -----------------------------------------------------------------
        function InitLineIdxs(obj)
            fields = propnames(obj.sections);
            for ii=1:length(fields)
                eval( sprintf('obj.sections.%s.lines = [0 0];', fields{ii}) );
            end
        end
        
        
        % -----------------------------------------------------------------
        function RemoveBlankLines(obj)
            % Identify lines in each section where actual text begins and
            % ends and remove the leading and trailing blank lines
            fields = propnames(obj.sections);
            for jj=1:length(fields)
                lines = eval( sprintf('obj.sections.%s.lines(1):obj.sections.%s.lines(2)', fields{jj}, fields{jj}) );
                
                % If there a zeroes in lines then section is invalid or
                % empty
                if ismember(0, lines)
                    continue;
                end
                
                % Find first non-blank line of text
                for iLine = lines
                    if ~isblankline(obj.helpstr{iLine})
                        eval( sprintf('obj.sections.%s.lines(1) = iLine;', fields{jj}) );
                        break;
                    end
                end
                
                % Find last non-blank line of text
                for iLine = fliplr(lines)
                    % Find first non-blank line of text
                    if ~isblankline(obj.helpstr{iLine})
                        eval( sprintf('obj.sections.%s.lines(2) = iLine;', fields{jj}) );
                        break;
                    end
                end
            end
        end
        
        
        % -----------------------------------------------------------------
        function EndPrevSection(obj, iLine) %#ok<INUSD>
            fields = propnames(obj.sections);
            for ii=1:length(fields)
                if eval( sprintf('obj.sections.%s.lines(1)>0 && obj.sections.%s.lines(2)==0', fields{ii}, fields{ii}) )
                    eval( sprintf('obj.sections.%s.lines(2) = iLine-1;', fields{ii}) );
                    break;
                end
            end
        end
        
        
        % -----------------------------------------------------------------
        function b = IsSectionName(obj, str)
            b = false;
            if isblankline(str)
                return;
            end
            str = strtrim(str);
            if ~isuppercase(str)
                return;
            end
            if str(end)~=':'
                return;
            end
            b = true;
        end
        
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            obj.funcname = obj2.funcname;
            obj.helpstr = obj2.helpstr;
            obj.sections = obj2.sections;
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = false;
            if isempty(obj.funcname)
                b=true;
            end
            if isempty(obj.helpstr)
                b=true;
            end
            if isempty(obj.sections)
                b=true;
            end
        end
        
        
        
        % ---------------------------------------------------------------------------------
        function Help(obj)
            funcname = '';
            if ~isdeployed()
                funcname = [obj.funcname, '.m'];
            else
                for ii = 1:length(obj.userfuncdir)
                    if exist([obj.userfuncdir{ii}, obj.funcname, '.m'], 'file')
                        funcname = [obj.userfuncdir{ii}, obj.funcname, '.m'];
                    end
                end
            end
            if isempty(funcname)
                return
            end
            obj.helpstr = str2cell_fast(help_local(funcname), [], 'keepblanks');
        end
               
    end
    
    
    methods (Static)
                
        % ----------------------------------------------------------------------------------
        function out = UserFuncDirs(arg)
            persistent userfuncdir;            
            if isempty(userfuncdir)
                userfuncdir = FindUserFuncDir(arg);
            end
            out = userfuncdir;
        end
   
    end
    
end

