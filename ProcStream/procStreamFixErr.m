function [procInput, err] = procStreamFixErr(err, procInput, iReg)

procFuncReg = procStreamReg2ProcFunc();

i=find(err==1);
for jj=length(i):-1:1
    
    % If function exists in registry, replace the bad or outdated version with
    % the current version of this function from the registry
    if iReg(i(jj))~=0
        % Copy field-by-field procFuncReg(iReg(i(jj))) to procInput.procFunc(i(jj))
        fields = fieldnames(procFuncReg(iReg(i(jj))));
        for ii=1:length(fields)
            eval( sprintf('procInput.procFunc(i(jj)).%s = procFuncReg(iReg(i(jj))).%s;', fields{ii}, fields{ii}) );
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
        procInput.procFunc(i(jj)) = [];        
    end
end


err = procStreamErrCheck(procInput);
