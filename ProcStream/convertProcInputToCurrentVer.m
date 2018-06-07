function procInput = convertProcInputToCurrentVer(procInput)

if isproperty(procInput,'procFunc') && ~isempty(procInput.procFunc)
    
    if isproperty(procInput.procFunc,'funcCall')
        procInput.procFunc.funcName = procInput.procFunc.funcCall;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCall');
    end
    if isproperty(procInput.procFunc,'funcCallArgIn')
        procInput.procFunc.funcArgIn = procInput.procFunc.funcCallArgIn;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCallArgIn');
    end
    if isproperty(procInput.procFunc,'funcCallArgOut')
        procInput.procFunc.funcArgOut = procInput.procFunc.funcCallArgOut;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCallArgOut');
    end
    if ~isproperty(procInput.procFunc,'funcNameUI')
        procInput.procFunc.funcNameUI = procInput.procFunc.funcName;
    end
    
    %{
    if ~isproperty(procInput.procFunc,'funcNameUI')
        funcParam: {[]}
    end
    if ~isproperty(procInput.procFunc,'funcNameUI')
        funcParamFormat: {[]}
    end
    if ~isproperty(procInput.procFunc,'funcNameUI')
        funcParamVal: {[]}
    end
    %}
    
    if ~isproperty(procInput.procFunc,'funcHelp')
        procInput.procFunc.funcHelp = InitHelp();
        procInput.procFunc = procStreamSetHelp(procInput.procFunc);
    elseif isempty(procInput.procFunc.funcHelp)
        procInput.procFunc.funcHelp = InitHelp();
        procInput.procFunc = procStreamSetHelp(procInput.procFunc);
    elseif isproperty(procInput.procFunc.funcHelp, 'funcName')
        if isempty(procInput.procFunc.funcHelp.funcName)
            procInput.procFunc = procStreamSetHelp(procInput.procFunc);            
        end
    end

end


