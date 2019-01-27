classdef FuncHelpClass < handle
    properties
        funcname;
        helpstr;
        sections;
    end
    
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
            sectionNames = {
                            'SYNTAX'
                            'UI NAME'
                            'DESCRIPTION'
                            'INPUT'
                            'OUTPUT'
                            'USAGE OPTIONS'
                            'TO DO'
                            'LOG'
                           };
            for ii=1:length(sectionNames)
                obj.AddSection(sectionNames{ii});
            end
            obj.ParseSections(funcname);
        end
        
        
        % ---------------------------------------------------------------
        function AddSection(obj, name)
            fieldname = name;
            fieldname(fieldname==' ')='';
            fieldname = lower(fieldname);
            eval( sprintf('obj.sections.%s = struct(''name'',name, ''lines'',[0,0], ''str'','''');', fieldname) );            
        end
        
        
        % -------------------------------------------------------------
        function ParseSections(obj, funcname)
            % This function parses the help of a proc stream function
            % into a help structure. The following is the help format
            % it expects:
            %
            % --------------------------------------
            % SYNTAX:
            % [p1,p2,...pn] = name(a1,a2,...am)
            %
            % UI NAME:
            % <User Interface Function Name>
            %
            % DESCRIPTION:
            % <General function description>
            %
            % INPUT:
            % a1 - <Description of a1>
            % a2 - <Description of a2>
            %    . . . . . . . . . .
            % am - <Description of am>
            %
            % OUPUT:
            % p1 - <Description of p1>
            % p2 - <Description of p2>
            %    . . . . . . . . . .
            % pn - <Description of pn>
            %
            % USAGE OPTIONS:
            % [p1,p2,...pn] = name(a1,a2,...am)
            % [p1,p2,...pn] = name(a1,a2,...am)
            %    . . . . . . . . . .
            % [p1,p2,...pn] = name(a1,a2,...am)
            %
            %
            % --------------------------------------
            %
            
            % Find the lines in the help that belong to each help section
            obj.FindSectionLines();
                        
            % Remove leading and trailing blank lines from each section
            obj.RemoveBlankLines();
            
            % Now that we have the lines associated with each help section,
            % assign the text from these lines to corresponding help sections.
            obj.AssignSectionText();
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
        function str = GetDescription(obj)
            str = '';
            if isproperty(obj.sections,'description')
                str = obj.sections.description.str;
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
        
    end
end