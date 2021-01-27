function b = ishandles(h)

b = false;
if isempty(h)
    return;
else
    for ii=1:length(h(:))
        if ~ishandle(h(ii))
            return;
        end
    end
end
b = true;

