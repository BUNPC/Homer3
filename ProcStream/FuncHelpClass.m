classdef FuncHelpClass < handle
    properties
        strs;
        callstr;
        usage;
        nameUI;
        genDescr;
        argInDescr;
        paramDescr;
        argOutDescr;
    end
    
    methods
        
        % -------------------------------------------------------------
        function obj = FuncHelpClass(varargin)            
            if nargin==0
                return;
            end
            func = varargin{1};
            
            obj.strs = {};
            obj.callstr = '';
            obj.usage = '';
            obj.nameUI = '';
            obj.genDescr = '';
            obj.argInDescr = '';
            obj.paramDescr = repmat({''},func.nParam,1);
            obj.argOutDescr = '';
            
            obj.Parse(func);
        end
        
        
        
        % -------------------------------------------------------------
        function Parse(obj, func)
            % This function parses the help of a proc stream function
            % into a help structure. The following is the help format
            % it expects:
            %
            % --------------------------------------
            % [p1,p2,...pn] = name(a1,a2,...am)
            %
            %
            % UI NAME:
            % <User Interface Function Name>
            %
            %
            % DESCRIPTION:
            % <General function description>
            %
            %
            % INPUT:
            % a1 - <Description of a1>
            % a2 - <Description of a2>
            %    . . . . . . . . . .
            % am - <Description of am>
            %
            %
            % OUPUT:
            % p1 - <Description of p1>
            % p2 - <Description of p2>
            %    . . . . . . . . . .
            % pn - <Description of pn>
            %
            % LOG:
            % <Person A, Date, and description of code modification made>
            % <Person B, Date, and description of code modification made>
            % . . . . . . . . .
            %
            % TO DO:
            % <Desription of changes which are needed in the future>
            %
            % --------------------------------------
            %
            % The LOG and TO DO are optional. These fields are less necessary
            % for a complete parsing  then the other fields.
            %
            % If this format isn't followed then this function tries to assign as
            % much of the help text as possible to the field genDescr, which is
            % used for the generic function description.
            %
            name       = func.name;
            param      = func.param;
            argIn      = func.argIn;
            argOut     = func.argOut;
            
            argIn      = procStreamParseArgsIn(argIn);
            argOut     = procStreamParseArgsOut(argOut);
            
            % helpStr is a cell array of strings. The first element of the cell
            % array is the call string (the kind you'd find in proceccOpt.cfg file.
            % The rest of the strings make up the help text.
            helpStr    = str2cell(help(name));
            
            nParam = length(param);
            nArgIn = length(argIn);
            nArgOut = length(argOut);
                       
            usageLines = [0 0];
            nameLines = [0 0];
            genDescrLines = [1,length(helpStr)];
            argInDescrLines = [0,0];
            paramDescrLines = [0,0];
            argOutDescrLines = [0,0];
            logDescrLines = [0,0];
            toDoDescrLines = [0,0];
            
            % Find the lines in the help string that belong to each help field
            for iLine=1:length(helpStr)
                if isempty(helpStr{iLine})
                    continue;
                end
                
                if obj.isFuncUsage(helpStr{iLine}, name, argIn, param, argOut)
                    usageLines(1) = iLine;
                    usageLines(2) = iLine;
                    genDescrLines(1) = iLine+1;
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'UI NAME'))
                    if usageLines(1)>0
                        usageLines(2) = iLine-1;
                    end
                    nameLines(1) = iLine+1;
                    nameLines(2) = iLine+1;
                    genDescrLines(1) = iLine+2;
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'DESCRIPTION'))
                    if nameLines(1)==0 && (usageLines(1)>0 && usageLines(2)==0)
                        usageLines(2) = iLine-1;
                    elseif nameLines(1)>0
                        nameLines(2) = iLine-1;
                    end
                    genDescrLines(1) = iLine;
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'INPUT'))
                    genDescrLines(2) = iLine-1;
                    if nArgIn>0
                        argInDescrLines(1) = iLine+1;
                    end
                end
                
                if argInDescrLines(1)>0 && argOutDescrLines(1)==0
                    iParam = obj.isParam(helpStr{iLine}, param);
                    if iParam>0
                        if iParam==1 && nArgIn>0
                            argInDescrLines(2) = iLine-1;
                        end
                        paramDescrLines(iParam,1) = iLine;
                        if iParam>1
                            paramDescrLines(iParam-1,2) = iLine-1;
                        end
                    end
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'OUTPUT'))
                    if nParam>0
                        paramDescrLines(end,2) = iLine-1;
                    elseif nArgIn>0
                        argInDescrLines(2) = iLine-1;
                    end
                    if nArgOut>0
                        argOutDescrLines(1) = iLine+1;
                        argOutDescrLines(2) = length(helpStr);
                    end
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'LOG'))
                    if nArgOut>0
                        argOutDescrLines(2) = iLine-1;
                    elseif nParam>0
                        paramDescrLines(end,2) = iLine-1;
                    end
                    logDescrLines(1) = iLine+1;
                    logDescrLines(2) = length(helpStr);
                end
                
                if ~isempty(strfind(helpStr{iLine}, 'TO DO'))
                    if logDescrLines(1)>0
                        logDescrLines(2) = iLine-1;
                    elseif nArgOut>0
                        argOutDescrLines(2) = iLine-1;
                    end
                    toDoDescrLines(1) = iLine+1;
                    toDoDescrLines(2) = length(helpStr);
                end
            end
            
            % Now that we have the lines associated with each help section, assign the
            % lines to corresponding help fields.
            for iLine = nameLines(1):nameLines(2)
                if iLine < 1 || isempty(helpStr{iLine})
                    continue;
                end
                obj.nameUI = sprintf('%s%s\n', obj.nameUI, helpStr{iLine});
            end
            
            for iLine = usageLines(1):usageLines(2)
                if iLine < 1 || isempty(helpStr{iLine})
                    continue;
                end
                obj.usage = sprintf('%s%s\n', obj.usage, helpStr{iLine});
            end
            
            for iLine = genDescrLines(1):genDescrLines(2)
                if iLine < 1 || isempty(helpStr{iLine})
                    continue;
                end
                obj.genDescr = sprintf('%s%s\n', obj.genDescr, helpStr{iLine});
            end
            
            for iLine = argInDescrLines(1):argInDescrLines(2)
                if iLine < 1 || isempty(helpStr{iLine})
                    continue;
                end
                obj.argInDescr = sprintf('%s%s\n', obj.argInDescr, helpStr{iLine});
            end
            
            for iParam=1:size(paramDescrLines,1)
                for iLine = paramDescrLines(iParam,1):paramDescrLines(iParam,2)
                    if iLine < 1 || isempty(helpStr{iLine})
                        continue;
                    end
                    obj.paramDescr{iParam} = sprintf('%s%s\n', obj.paramDescr{iParam}, helpStr{iLine});
                end
            end
            
            for iLine = argOutDescrLines(1):argOutDescrLines(2)
                if iLine < 1 || isempty(helpStr{iLine})
                    continue;
                end
                obj.argOutDescr = sprintf('%s%s\n', obj.argOutDescr, helpStr{iLine});
            end            
        end
    end
       
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
            
        % -----------------------------------------------------------------
        function B = isFuncUsage(obj, helpStr, name, argIn, param, argOut)            
            B=0;            
            if ~includes(helpStr, [name '('])
                return;
            end
            %{
                for ii=1:length(argIn)
                    if isempty(strfind(helpStr,argIn{ii}))
                        return;
                    end
                end
                for ii=1:length(param)
                    if isempty(strfind(helpStr,param{ii}))
                        return;
                    end
                end
                for ii=1:length(argOut)
                    if isempty(strfind(helpStr,argOut{ii}))
                        return;
                    end
                end
            %}
            B=1;
        end

        
        % -----------------------------------------------------------------
        function iParam = isParam(obj, helpStr, param)
            iParam=0;
            if isempty(helpStr)
                return;
            end
            
            % Remove leading white spaces
            while ~isstrprop(helpStr(1),'alphanum')
                helpStr(1)=[];
                if isempty(helpStr)
                    return;
                end
            end
            
            for ii=1:length(param)
                k1=strfind(helpStr,[param{ii} ':']);
                k2=strfind(helpStr,[param{ii} ' - ']);
                if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
                    iParam=ii;
                    return;
                end
            end
        end     


        % -----------------------------------------------------------------
        function iArgIn = isArgIn(obj, helpStr, argIn)
            
            iArgIn=0;
            if isempty(helpStr)
                return;
            end
            
            % Remove leading white spaces
            while ~isstrprop(helpStr(1),'alphanum')
                helpStr(1)=[];
                if isempty(helpStr)
                    return;
                end
            end
            
            for ii=1:length(argIn)
                k1=strfind(helpStr,[argIn{ii} ':']);
                k2=strfind(helpStr,[argIn{ii} ' - ']);
                if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
                    iArgIn=ii;
                    return;
                end
            end
        end         

   
        % -----------------------------------------------------------------
        function iArgOut = isArgOut(obj, helpStr, argOut)            
            iArgOut=0;
            if isempty(helpStr)
                return;
            end
            
            % Remove leading white spaces
            while ~isstrprop(helpStr(1),'alphanum')
                helpStr(1)=[];
                if isempty(helpStr)
                    return;
                end
            end
            for ii=1:length(argOut)
                k1=strfind(helpStr,[argOut{ii} ':']);
                k2=strfind(helpStr,[argOut{ii} ' - ']);
                if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
                    iArgOut=ii;
                    return;
                end
            end
        end
        
        
    end
end