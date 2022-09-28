function b = isblankline(s)
b = true;
if all(isspace(s))
    return;
end
if isempty(s)
    return;
end
b = false;

