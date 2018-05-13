function procFunc = procStreamHelpParse(procFuncReg, procFunc)

for iFunc=1:length(procFunc)
    for jj=1:length(procFuncReg)
        if strcmp(procFunc(iFunc).funcName, procFuncReg(jj).funcName)
            f1 = procFunc(iFunc);
            f2 = procFuncReg(jj);

            if procStreamFuncMatch(f1,f2)

                procFunc(iFunc).funcHelp = procStreamParseFuncHelp(procFuncReg, jj);
                if ~isempty(procFunc(iFunc).funcHelp.funcNameUI)
                    procFunc(iFunc).funcNameUI = procFunc(iFunc).funcHelp.funcNameUI;
                end
                
            end
        end
    end
end

