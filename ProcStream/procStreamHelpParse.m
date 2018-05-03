function procFunc = procStreamHelpParse(currElem)

procFunc = currElem.procElem.procInput.procFunc;

funcReg.call = procStreamReg(currElem.procElem);
funcReg.help = procStreamRegHelp(currElem);
for ii=1:length(funcReg.call)
    procInputReg = procStreamParse(funcReg.call{ii}, currElem.procElem);
    temp.funcName{ii}        = procInputReg.procFunc.funcName{1};
    temp.funcArgOut{ii}      = procInputReg.procFunc.funcArgOut{1};
    temp.funcArgIn{ii}       = procInputReg.procFunc.funcArgIn{1};
    temp.nFuncParam(ii)      = procInputReg.procFunc.nFuncParam(1);
    temp.nFuncParamVar(ii)   = procInputReg.procFunc.nFuncParamVar(1);
    temp.funcParam{ii}       = procInputReg.procFunc.funcParam{1};
    temp.funcParamFormat{ii} = procInputReg.procFunc.funcParamFormat{1};
    temp.funcParamVal{ii}    = procInputReg.procFunc.funcParamVal{1};
    temp.funcHelpStrArr{ii}  = funcReg.help{ii};
end
temp.nFunc = ii;
procInputReg.procFunc = temp;

for iFunc=1:length(procFunc.funcName)
    for jj=1:procInputReg.procFunc.nFunc
        if strcmp(procFunc.funcName{iFunc},procInputReg.procFunc.funcName{jj})
            f1.funcName        = procFunc.funcName{iFunc};
            f1.funcArgOut      = procFunc.funcArgOut{iFunc};
            f1.funcArgIn       = procFunc.funcArgIn{iFunc}; 
            f1.nFuncParam      = procFunc.nFuncParam(iFunc);
            f1.nFuncParamVar   = procFunc.nFuncParamVar(iFunc);
            f1.funcParam       = procFunc.funcParam{iFunc};
            f1.funcParamFormat = procFunc.funcParamFormat{iFunc};
            f1.funcParamVal    = procFunc.funcParamFormat{iFunc};

            f2.funcName        = procInputReg.procFunc.funcName{jj};
            f2.funcArgOut      = procInputReg.procFunc.funcArgOut{jj};
            f2.funcArgIn       = procInputReg.procFunc.funcArgIn{jj}; 
            f2.nFuncParam      = procInputReg.procFunc.nFuncParam(jj);
            f2.nFuncParamVar   = procInputReg.procFunc.nFuncParamVar(jj);
            f2.funcParam       = procInputReg.procFunc.funcParam{jj};
            f2.funcParamFormat = procInputReg.procFunc.funcParamFormat{jj};
            f2.funcParamVal    = procInputReg.procFunc.funcParamFormat{jj};

            if procStreamFuncMatch(f1,f2)

                procFunc.funcHelp{iFunc} = procStreamParseFuncHelp(procInputReg.procFunc, jj, currElem.procElem);
                if ~isempty(procFunc.funcHelp{iFunc}.funcNameUI)
                    procFunc.funcNameUI{iFunc} = procFunc.funcHelp{iFunc}.funcNameUI;
                end
                
            end
        end
    end
end

