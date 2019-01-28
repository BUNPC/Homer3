classdef FuncHelpClass < handle
    properties
        funcname;
        helpstr;
        defaultsections;
        sections;
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
            if nargin==0
                return;
            end
            obj.funcname = funcname;
            obj.helpstr = str2cell(help(funcname), [], 'keepblanks');
            obj.defaultsections = {
                            'SYNTAX'
                            'UI NAME'
                            'DESCRIPTION'
                            'INPUT'
                            'OUTPUT'
                            'USAGE OPTIONS'
                            'PARAMETERS'
                            'TO DO'
                            'LOG'
                           };
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
            % any other text on that line. For a sub-section to be considered a sub-section, 
            % the line which it's on must begin with a single word (no spaces) followed 
            % by a ':', ' - ', or '--'.
            %
            % In addition to the generic parsing of sections, this class
            % also provides methods for accessing specific 'default'
            % sections if they happen to exist in the help comments. Those
            % sections are 
            %
            %       Default Sections    Associated method 
            %       --------------------------------------
            %       'SYNTAX:'           % GetSyntax()
            %       'UI NAME:'          % GetUiname()
            %       'DESCRIPTION:'      % GetDescr()
            %       'INPUT(S):'         % GetInput()
            %       'OUTPUT(S):'        % GetOutput()
            %       'USAGE OPTIONS:'    % GetUsageOptions()
            %       'PARAMETERS:'       % GetParams()
            %
            % New methods can be added for any new default sections added to this 
            % class in the future 
            %
            % Example from Homer3: formal descrition of user functions 
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
            % [r11,r12,...,r1N] = <funcname>(a11,...,a1M,p1,...,pL):  <Usage option 1 user-friendly name>
            %    . . . . . . . . . .
            % [rK1,rK2,...,rKN] = <funcname>(aK1,...,aKM,p1,...,pL):  <Usage option K user-friendly name>
            %
            % PARAMETERS:
            % p1: [v11,...,v1J]
            %    . . . . . . . . . .
            % pL: [vL1,...,vLJ]
            %
            %
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
            for ii=1:length(obj.helpstr)
                if obj.IsSectionName(obj.helpstr{ii})
                    k = find(obj.helpstr{ii}==':');
                    sect{kk,:} = strtrim(obj.helpstr{ii}(1:k-1));
                    kk=kk+1;
                end
            end
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
            strs = str2cell(eval(sprintf('obj.sections.%s.str', section)), [], 'keepblanks');
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
            strs = eval(sprintf('str2cell(obj.sections.%s.str, [], ''keepblanks'')', section));
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
            name = strtrim(strs{iLine}(1:(k-d)));
            k = k(1);
        end
        
        
        % -------------------------------------------------------------
        function AssignSubSectionText(obj, section)
            strs = str2cell(eval(sprintf('obj.sections.%s.str', section)), [], 'keepblanks');
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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods for accessing default help info 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    methods
               
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
            if isproperty(obj.sections,'input')
                subsections = obj.sections.input.subsections;
            end
            if isproperty(obj.sections,'inputs')
                subsections = obj.sections.inputs.subsections;
            end
            for ii=1:length(subsections)
                if strcmp(param, subsections(ii).name)
                    str = subsections(ii).str;
                end
            end
        end

        
        % -------------------------------------------------------------
        function str = GetParamNames(obj)
            str = '';
            if isproperty(obj.sections,'input')
                subsections = obj.sections.input.subsections;
            end
            if isproperty(obj.sections,'inputs')
                subsections = obj.sections.inputs.subsections;
            end
            for ii=1:length(subsections)
                if strcmp(param, subsections(ii).name)
                    str = subsections(ii).str;
                end
            end
        end
        
        
        % -------------------------------------------------------------
        function str = GetUsageOptions(obj)
            str = '';
            if isproperty(obj.sections.usageO,'input')
                subsections = obj.sections.input.subsections;
            end
            if isproperty(obj.sections,'inputs')
                subsections = obj.sections.inputs.subsections;
            end
            for ii=1:length(subsections)
                if strcmp(param, subsections(ii).name)
                    str = subsections(ii).str;
                end
            end
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
                for iLine = reverse(lines)
                    % Find first non-blank line of text
                    if ~isblankline(obj.helpstr{iLine})
                        eval( sprintf('obj.sections.%s.lines(2) = iLine;', fields{jj}) );
                        break;
                    end
                end
            end
        end

        
        % -----------------------------------------------------------------
        function EndPrevSection(obj, iLine)
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
        
    end
end