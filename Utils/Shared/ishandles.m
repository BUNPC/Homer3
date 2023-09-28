function b = ishandles(h)

b = false;
if isempty(h)
    return;
end
if isa(h,'function_handle')
    return;
end
for ii=1:length(h(:))
    if ~ishandle(h(ii))
        return;
    end
end
b = true;

