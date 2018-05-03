function s1=copyStructFieldByField(s1,s2,type)

if exist('type','var') && strcmp(type,'procInput')
    s2 = convertProcInputToCurrentVer(s2);
end

if ~strcmp(class(s1),class(s2))
    return;
end

if strcmp(class(s1),'struct')

    fields = fieldnames(s2);
    for ii=1:length(fields)
        if isempty(s1)
            s1 = struct();
        end
        field_class = eval(sprintf('class(s2.%s)',fields{ii}));
        if ~isfield(s1,fields{ii})
            if strcmp(field_class,'cell')
                field_arg='{}';
            else
                field_arg='[]';
            end
            eval(sprintf('s1.%s = %s(%s);',fields{ii},field_class,field_arg));
        end
        eval(sprintf('s1.%s = copyStructFieldByField(s1.%s,s2.%s);',fields{ii},fields{ii},fields{ii}));
    end

else

    s1 = s2;

end



% ------------------------------------------------------------
function procInput = convertProcInputToCurrentVer(procInput)

if isfield(procInput,'procFunc') && ~isempty(procInput.procFunc)
    if isfield(procInput.procFunc,'funcCall')
        procInput.procFunc.funcName = procInput.procFunc.funcCall;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCall');
    end
    if isfield(procInput.procFunc,'funcCallArgIn')
        procInput.procFunc.funcArgIn = procInput.procFunc.funcCallArgIn;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCallArgIn');
    end
    if isfield(procInput.procFunc,'funcCallArgOut')
        procInput.procFunc.funcArgOut = procInput.procFunc.funcCallArgOut;
        procInput.procFunc = rmfield(procInput.procFunc,'funcCallArgOut');
    end
    if ~isfield(procInput.procFunc,'funcNameUI')
        procInput.procFunc.funcNameUI = procInput.procFunc.funcName;
    end
end
