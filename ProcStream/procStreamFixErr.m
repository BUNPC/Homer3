function [procInput, err] = procStreamFixErr(err, procInput, iReg)

funcReg = procStreamReg2ProcFunc();

i=find(err==1);
for jj=length(i):-1:1
    
    % If function exists in registry, replace the bad or outdated version with
    % the current version of this function from the registry
    if iReg(i(jj))~=0
        % Copy field-by-field funcReg(iReg(i(jj))) to procInput.func(i(jj))
        fields = fieldnames(funcReg(iReg(i(jj))));
        for ii=1:length(fields)
            eval( sprintf('procInput.func(i(jj)).%s = funcReg(iReg(i(jj))).%s;', fields{ii}, fields{ii}) );
        end
        
        for p=1:length(procInput.func(i(jj)).param)
            assignmentStr = sprintf('procInput.param.%s_%s = [%s];', ...
                                    procInput.func(i(jj)).name,...
                                    procInput.func(i(jj)).param{p},...
                                    procInput.func(i(jj)).paramFormat{p});
            eval(sprintf(assignmentStr, procInput.func(i(jj)).paramVal{p}));
        end
        
        % Else the function doesn't exist in the registry and we simply delete it
        % from the processing stream.
    else
        procInput.func(i(jj)) = [];        
    end
end


err = procStreamErrCheck(procInput);
