function setListboxValueToLast(h)
foo = get(h, 'string');
if iscell(foo)
    idx_lastline = length(foo);
elseif ischar(foo)
    idx_lastline = size(foo,1);
end
set(h, 'value', idx_lastline);



