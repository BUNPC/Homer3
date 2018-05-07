function procFunc = procStreamHelpParse(currElem)

procFunc = currElem.procElem.procInput.procFunc;

calls    = procStreamReg(currElem.procElem);
helpstrs = procStreamRegHelp(currElem);
for ii=1:length(calls)
    procInputReg = procStreamParse(calls{ii}, currElem.procElem);
    temp.procFunc(ii) = procInputReg.procFunc(1);
    temp.procFunc(ii).funcHelpStr  = helpstrs{ii};
end
procInputReg.procFunc = temp.procFunc;

for iFunc=1:length(procFunc)
    for jj=1:length(procInputReg.procFunc)
        if strcmp(procFunc(iFunc).funcName, procInputReg.procFunc(jj).funcName)
            f1 = procFunc(iFunc);
            f2 = procInputReg.procFunc(jj);

            if procStreamFuncMatch(f1,f2)

                procFunc(iFunc).funcHelp = procStreamParseFuncHelp(procInputReg.procFunc, jj);
                if ~isempty(procFunc(iFunc).funcHelp.funcNameUI)
                    procFunc(iFunc).funcNameUI = procFunc(iFunc).funcHelp.funcNameUI;
                end
                
            end
        end
    end
end

