function b = includes(s1, s2)

if verLessThan('matlab','9.1')
    b = isempty(strfind(s1,s2));
else
    b = contains(s1,s2);
end