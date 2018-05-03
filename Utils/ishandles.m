function b = ishandles(h)

if isempty(h)
    b = 0;
else
    b = ishandle(h);
end
