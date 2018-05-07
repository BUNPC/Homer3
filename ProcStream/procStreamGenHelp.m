function procStreamGenHelp(currElem)

% Usage:
%
% 1) Launch homer2
% 2) Select the processing type for which you want to generate a proc
% stream help 
% 3) at the matlab command line type 'global hmr'. 
% 4) call the function procStreamGenHelp passing hmr.currElem as argument 
%
%     procStreamGenHelp(hmr.currElem);
%

procStreamRegStr = procStreamReg(currElem.procElem);
for ii=1:length(procStreamRegStr)
    procInputReg = procStreamParse(procStreamRegStr{ii}, currElem.procElem);
    temp.funcName{ii}        = procInputReg.procFunc.funcName{1};
    temp.funcArgOut{ii}      = procInputReg.procFunc.funcArgOut{1};
    temp.funcArgIn{ii}       = procInputReg.procFunc.funcArgIn{1};
    temp.nFuncParam(ii)      = procInputReg.procFunc.nFuncParam(1);
    temp.nFuncParamVar(ii)   = procInputReg.procFunc.nFuncParamVar(1);
    temp.funcParam{ii}       = procInputReg.procFunc.funcParam{1};
    temp.funcParamFormat{ii} = procInputReg.procFunc.funcParamFormat{1};
    temp.funcParamVal{ii}    = procInputReg.procFunc.funcParamVal{1};
end
temp.nFunc = ii;
procInputReg.procFunc = temp;

% Create procStreamRegHelp.m in the same directory as the
% procStreamReg.m
if strcmpi(currElem.procElem.type, 'group')
    funcRegHelpName = 'procStreamRegHelpGroup';
    funcRegFilename = 'procStreamRegGroup.m';
elseif strcmpi(currElem.procElem.type, 'subj')
    funcRegHelpName = 'procStreamRegHelpSubj';
    funcRegFilename = 'procStreamRegSubj.m';
elseif strcmpi(currElem.procElem.type, 'run')
    funcRegHelpName = 'procStreamRegHelpRun';
    funcRegFilename = 'procStreamRegRun.m';
end
funcRegHelpFilename = [funcRegHelpName '.m'];

procStreamRegPath = which(funcRegFilename);
k = findstr(procStreamRegPath, funcRegFilename);
procStreamRegPath = [procStreamRegPath(1:k-1) funcRegHelpFilename];
fid = fopen(procStreamRegPath, 'w');
fprintf(fid,'function helpReg = %s()\n', funcRegHelpName);
fprintf(fid,'helpReg = {...\n');

nFuncs = length(procInputReg.procFunc.funcName);
iFunc=1;
while 1
    C = procStreamGenHelpFunc(procInputReg.procFunc(iFunc).funcName);
    funcDescr = C{1};
    fprintf(fid,'{...\n');
    iLine=1;
    while 1
        nLines = size(funcDescr,1);
        if iLine<nLines
            fprintf(fid,'''%s'',...\n',funcDescr{iLine});
        else
            fprintf(fid,'''%s''...\n',funcDescr{iLine});
            break;
        end
        iLine=iLine+1;
    end
    if iFunc < nFuncs
        fprintf(fid,'},...\n\n');
    else
        fprintf(fid,'}...\n');
        break;
    end
    iFunc=iFunc+1;
end
fprintf(fid,'};\n');
fclose(fid);
