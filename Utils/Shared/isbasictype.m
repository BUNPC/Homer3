function b = isbasictype(v)

if isstruct(v) || isobject(v)
    b = false;
elseif iscell(v)
    b = false;
else
    b = true;
end