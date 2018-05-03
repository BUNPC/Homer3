function [procInput err] = procStreamFixErr(err, procInput, procElem, iReg, procInputReg)

i=find(err==1);
for jj=length(i):-1:1

    % If function exists in registry, replace the bad or outdated version with 
    % the current version of this function from the registry
    if iReg(i(jj))~=0
        procInput.procFunc.funcName{i(jj)}      = procInputReg.procFunc.funcName{iReg(i(jj))};
        procInput.procFunc.funcArgOut{i(jj)}    = procInputReg.procFunc.funcArgOut{iReg(i(jj))};
        procInput.procFunc.funcArgIn{i(jj)}     = procInputReg.procFunc.funcArgIn{iReg(i(jj))}; 
        procInput.procFunc.nFuncParam(i(jj))    = procInputReg.procFunc.nFuncParam(iReg(i(jj)));
        procInput.procFunc.nFuncParamVar(i(jj)) = procInputReg.procFunc.nFuncParamVar(iReg(i(jj)));
        
        funcParam0       = procInput.procFunc.funcParam{i(jj)};
        funcParamFormat0 = procInput.procFunc.funcParamFormat{i(jj)};
        funcParamVal0    = procInput.procFunc.funcParamVal{i(jj)};
        
        procInput.procFunc.funcParam{i(jj)}       = procInputReg.procFunc.funcParam{iReg(i(jj))};
        procInput.procFunc.funcParamFormat{i(jj)} = procInputReg.procFunc.funcParamFormat{iReg(i(jj))};
        procInput.procFunc.funcParamVal{i(jj)}    = procInputReg.procFunc.funcParamVal{iReg(i(jj))};
        for p=1:length(funcParam0)
            for q=1:length(procInput.procFunc.funcParam{i(jj)})
                if strcmp(funcParam0{p}, procInput.procFunc.funcParam{i(jj)}{q}) && ...
                    strcmp(funcParamFormat0{p}, procInput.procFunc.funcParamFormat{i(jj)}{q})
                
                    procInput.procFunc.funcParamVal{i(jj)}{q} = funcParamVal0{p};                

                end 
            end
        end
        
        for p=1:length(procInput.procFunc.funcParam{i(jj)})
            assignmentStr = sprintf('procInput.procParam.%s_%s = [%s];', ...
                                      procInput.procFunc.funcName{i(jj)},...
                                      procInput.procFunc.funcParam{i(jj)}{p},...
                                      procInput.procFunc.funcParamFormat{i(jj)}{p});
            eval(sprintf(assignmentStr, procInput.procFunc.funcParamVal{i(jj)}{p}));
        end

    % Else the function doesn't exist in the registry and we simply delete it 
    % from the processing stream.
    else
        fields = fieldnames(procInput.procParam);
        for ii=1:length(fields)
            if ~isempty(findstr(fields{ii}, [procInput.procFunc.funcName{i(jj)} '_']))
                procInput.procParam = rmfield(procInput.procParam,fields{ii});
            end
        end
        procInput.procFunc.nFunc=procInput.procFunc.nFunc-1;
        procInput.procFunc.funcName(i(jj)) = [];
        procInput.procFunc.funcNameUI(i(jj)) = [];
        procInput.procFunc.funcArgOut(i(jj)) = [];
        procInput.procFunc.funcArgIn(i(jj)) = [];
        procInput.procFunc.nFuncParam(i(jj)) = [];
        procInput.procFunc.nFuncParamVar(i(jj)) = [];
        procInput.procFunc.funcParam(i(jj)) = [];
        procInput.procFunc.funcParamFormat(i(jj)) = [];
        procInput.procFunc.funcParamVal(i(jj)) = [];
        
    end
end


switch(procElem.type)
case 'group'
    err = procStreamErrCheckGroup(procElem.procInput);
case 'subj'
    err = procStreamErrCheckSubj(procElem.procInput);
case 'run'
    err = procStreamErrCheckRun(procElem.procInput);
end

