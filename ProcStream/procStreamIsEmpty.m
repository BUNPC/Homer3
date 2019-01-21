function b = procStreamIsEmpty(procInput)

b=0;

if isempty(procInput)
    b=1;
    return;
end

if ~isproperty(procInput, 'func')
    b=1;
    return;
end

if isempty(procInput.func)
    b=1;
    return;
end

% Now that we know we have a non-empty procFun, check to see if at least
% one VALID function is present 
b=1;
for ii=1:length(procInput.func)
    if ~isempty(procInput.func(ii).funcName) && ~isempty(procInput.func(ii).funcArgOut)
        b=0;
        return;
    end
end
