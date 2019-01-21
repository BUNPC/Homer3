function funcHelp = procStreamParseFuncHelp(func)

% This function parses the help of a proc stream function 
% into a help structure. The following is the help format 
% it expects:
%  
% --------------------------------------
% [p1,p2,...pn] = funcName(a1,a2,...am)
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

funcName       = func.funcName;
funcParam      = func.funcParam;
funcArgIn      = func.funcArgIn;
funcArgOut     = func.funcArgOut;

funcArgIn      = procStreamParseArgsIn(funcArgIn);
funcArgOut     = procStreamParseArgsOut(funcArgOut);

% funcHelpStr is a cell array of strings. The first element of the cell
% array is the call string (the kind you'd find in proceccOpt.cfg file. 
% The rest of the strings make up the help text. 
funcHelpStr    = str2cell(help(funcName));

nParam = length(funcParam);
nArgIn = length(funcArgIn);
nArgOut = length(funcArgOut);

funcHelp = InitHelp(nParam);

usageLines = [0 0];
nameLines = [0 0];
genDescrLines = [1,length(funcHelpStr)];
argInDescrLines = [0,0];
paramDescrLines = [0,0];
argOutDescrLines = [0,0];
logDescrLines = [0,0];
toDoDescrLines = [0,0];


% Find the lines in the help string that belong to each funcHelp field
for iLine=1:length(funcHelpStr)
    if isempty(funcHelpStr{iLine})
        continue;
    end

    if isFuncUsage(funcHelpStr{iLine},funcName,funcArgIn,funcParam,funcArgOut)
        usageLines(1) = iLine;
        usageLines(2) = iLine;
        genDescrLines(1) = iLine+1;
    end

    if ~isempty(strfind(funcHelpStr{iLine},'UI NAME'))
        if usageLines(1)>0
            usageLines(2) = iLine-1;
        end
        nameLines(1) = iLine+1;
        nameLines(2) = iLine+1;
        genDescrLines(1) = iLine+2;
    end

    if ~isempty(strfind(funcHelpStr{iLine},'DESCRIPTION'))
        if nameLines(1)==0 && (usageLines(1)>0 && usageLines(2)==0)
            usageLines(2) = iLine-1;
        elseif nameLines(1)>0
            nameLines(2) = iLine-1;
        end
        genDescrLines(1) = iLine;
    end

    if ~isempty(strfind(funcHelpStr{iLine},'INPUT'))
        genDescrLines(2) = iLine-1;
        if nArgIn>0
            argInDescrLines(1) = iLine+1;
        end
    end

    if argInDescrLines(1)>0 && argOutDescrLines(1)==0 
        iParam = isParam(funcHelpStr{iLine},funcParam);
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

    if ~isempty(strfind(funcHelpStr{iLine},'OUTPUT'))
        if nParam>0
            paramDescrLines(end,2) = iLine-1;
        elseif nArgIn>0
            argInDescrLines(2) = iLine-1;
        end
        if nArgOut>0
            argOutDescrLines(1) = iLine+1;
            argOutDescrLines(2) = length(funcHelpStr);
        end
    end

    if ~isempty(strfind(funcHelpStr{iLine},'LOG'))
        if nArgOut>0
            argOutDescrLines(2) = iLine-1;
        elseif nParam>0
            paramDescrLines(end,2) = iLine-1;
        end
        logDescrLines(1) = iLine+1;
        logDescrLines(2) = length(funcHelpStr);
    end

    if ~isempty(strfind(funcHelpStr{iLine},'TO DO'))
        if logDescrLines(1)>0
            logDescrLines(2) = iLine-1;
        elseif nArgOut>0
            argOutDescrLines(2) = iLine-1;
        end
        toDoDescrLines(1) = iLine+1;
        toDoDescrLines(2) = length(funcHelpStr);
    end
end


% Now that we have the lines associated with each help section, assign the
% lines to corresponding funcHelp fields. 
for iLine = nameLines(1):nameLines(2)
    if iLine < 1 || isempty(funcHelpStr{iLine})
        continue;
    end
    funcHelp.funcNameUI = sprintf('%s%s\n', funcHelp.funcNameUI, funcHelpStr{iLine});
end

for iLine = usageLines(1):usageLines(2)
    if iLine < 1 || isempty(funcHelpStr{iLine})
        continue;
    end
    funcHelp.usage = sprintf('%s%s\n', funcHelp.usage, funcHelpStr{iLine});
end

for iLine = genDescrLines(1):genDescrLines(2)
    if iLine < 1 || isempty(funcHelpStr{iLine})
        continue;
    end
    funcHelp.genDescr = sprintf('%s%s\n', funcHelp.genDescr, funcHelpStr{iLine});
end

for iLine = argInDescrLines(1):argInDescrLines(2)
    if iLine < 1 || isempty(funcHelpStr{iLine})
        continue;
    end
    funcHelp.argInDescr = sprintf('%s%s\n', funcHelp.argInDescr, funcHelpStr{iLine});
end

for iParam=1:size(paramDescrLines,1)
    for iLine = paramDescrLines(iParam,1):paramDescrLines(iParam,2)
        if iLine < 1 || isempty(funcHelpStr{iLine})
            continue;
        end
        funcHelp.paramDescr{iParam} = sprintf('%s%s\n', funcHelp.paramDescr{iParam}, ...
                                              funcHelpStr{iLine});
    end
end

for iLine = argOutDescrLines(1):argOutDescrLines(2)
    if iLine < 1 || isempty(funcHelpStr{iLine})
        continue;
    end
    funcHelp.argOutDescr = sprintf('%s%s\n', funcHelp.argOutDescr,funcHelpStr{iLine});
end




% -----------------------------------------------------------------
function B = isFuncUsage(funcHelpStr,funcName,funcArgIn,funcParam,funcArgOut)

B=0;

if isempty(strfind(funcHelpStr,[funcName '(']))
    return;
end

%{
for ii=1:length(funcArgIn)
    if isempty(strfind(funcHelpStr,funcArgIn{ii}))
        return;
    end
end
for ii=1:length(funcParam)
    if isempty(strfind(funcHelpStr,funcParam{ii}))
        return;
    end
end
for ii=1:length(funcArgOut)
    if isempty(strfind(funcHelpStr,funcArgOut{ii}))
        return;
    end
end
%}

B=1;




% -----------------------------------------------------------------
function iParam = isParam(funcHelpStr,funcParam)

iParam=0;
if isempty(funcHelpStr)
    return;
end

% Remove leading white spaces
while ~isstrprop(funcHelpStr(1),'alphanum')
    funcHelpStr(1)=[];
    if isempty(funcHelpStr)
        return;
    end
end

for ii=1:length(funcParam)
    k1=strfind(funcHelpStr,[funcParam{ii} ':']);
    k2=strfind(funcHelpStr,[funcParam{ii} ' - ']);
    if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
        iParam=ii;
        return;
    end    
end



% -----------------------------------------------------------------
function iArgIn = isArgIn(funcHelpStr,funcArgIn)

iArgIn=0;
if isempty(funcHelpStr)
    return;
end

% Remove leading white spaces
while ~isstrprop(funcHelpStr(1),'alphanum')
    funcHelpStr(1)=[];
    if isempty(funcHelpStr)
        return;
    end
end

for ii=1:length(funcArgIn)
    k1=strfind(funcHelpStr,[funcArgIn{ii} ':']);
    k2=strfind(funcHelpStr,[funcArgIn{ii} ' - ']);
    if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
        iArgIn=ii;
        return;
    end    
end



% -----------------------------------------------------------------
function iArgOut = isArgOut(funcHelpStr,funcArgOut)

iArgOut=0;
if isempty(funcHelpStr)
    return;
end

% Remove leading white spaces
while ~isstrprop(funcHelpStr(1),'alphanum')
    funcHelpStr(1)=[];
    if isempty(funcHelpStr)
        return;
    end
end

for ii=1:length(funcArgOut)
    k1=strfind(funcHelpStr,[funcArgOut{ii} ':']);
    k2=strfind(funcHelpStr,[funcArgOut{ii} ' - ']);
    if (~isempty(k1) && k1(1)==1) || (~isempty(k2) && k2(1)==1)
        iArgOut=ii;
        return;
    end    
end



