function b = procStreamIsEmpty(procInput)

b=0;

if isempty(procInput)
    b=1;
    return;
end

if ~isproperty(procInput, 'procFunc')
    b=1;
    return;
end

if isempty(procInput.procFunc)
    b=1;
    return;
end

% Now that we know we have a non-empty procFun, check to see if at least
% one VALID function is present 
b=1;
for ii=1:length(procInput.procFunc)
    if ~isempty(procInput.procFunc(ii).funcName) && ~isempty(procInput.procFunc(ii).funcArgOut)
        b=0;
        return;
    end
end
