function [procInput, err] = procStreamFixErr(err, procInput, iReg)

procFuncReg = procStreamReg2ProcFunc();

i=find(err==1);
for jj=length(i):-1:1
    
    % If function exists in registry, replace the bad or outdated version with
    % the current version of this function from the registry
    if iReg(i(jj))~=0
        procInput.procFunc(i(jj)) = procFuncReg(iReg(i(jj)));               
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


err = procStreamErrCheck(procInput);
