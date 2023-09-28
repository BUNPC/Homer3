function b = isvalidfuncname(s)
b = false;
if nargin==0
    return;
end
if ~ischar(s)
    return;
end
if isempty(s)
    return;
end

% First char has to be a letter
if (s(1)<'A' || s(1)>'Z') && (s(1)<'a' || s(1)>'z') 
    return;
end
b = true;