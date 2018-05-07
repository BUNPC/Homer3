function [procInput, err] = procStreamFixErr(err, procInput, procElem, iReg, procInputReg)

i=find(err==1);
for jj=length(i):-1:1
    
    % If function exists in registry, replace the bad or outdated version with
    % the current version of this function from the registry
    if iReg(i(jj))~=0
        procInput.procFunc(i(jj)) = procInputReg.procFunc(iReg(i(jj)));
        
        funcParam0       = procInput.procFunc(i(jj)).funcParam;
        funcParamFormat0 = procInput.procFunc(i(jj)).funcParamFormat;
        funcParamVal0    = procInput.procFunc(i(jj)).funcParamVal;
        
        procInput.procFunc(i(jj)).funcParam       = procInputReg.procFunc(iReg(i(jj))).funcParam;
        procInput.procFunc(i(jj)).funcParamFormat = procInputReg.procFunc(iReg(i(jj))).funcParamFormat;
        procInput.procFunc(i(jj)).funcParamVal    = procInputReg.procFunc(iReg(i(jj))).funcParamVal;
        for p=1:length(funcParam0)
            for q=1:length(procInput.procFunc)
                if strcmp(funcParam0{p}, procInput.procFunc(i(jj)).funcParam{q}) && ...
                   strcmp(funcParamFormat0{p}, procInput.procFunc(i(jj)).funcParamFormat{q})
                    
                    procInput.procFunc(i(jj)).funcParamVal{q} = funcParamVal0{p};
                    
                end
            end
        end
        
        for p=1:length(procInput.procFunc(i(jj)).funcParam)
            assignmentStr = sprintf('procInput.procParam.%s_%s = [%s];', ...
                procInput.procFunc(i(jj)).funcName,...
                procInput.procFunc(i(jj)).funcParam{p},...
                procInput.procFunc(i(jj)).funcParamFormat{p});
            eval(sprintf(assignmentStr, procInput.procFunc(i(jj)).funcParamVal{p}));
        end
        
        % Else the function doesn't exist in the registry and we simply delete it
        % from the processing stream.
    else
        fields = fieldnames(procInput.procParam);
        for ii=1:length(fields)
            if ~isempty(findstr(fields{ii}, [procInput.procFunc(i(jj)).funcName, '_']))
                procInput.procParam = rmfield(procInput.procParam,fields{ii});
            end
        end
        procInput.procFunc(i(jj)) = InitProcFunc();        
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

