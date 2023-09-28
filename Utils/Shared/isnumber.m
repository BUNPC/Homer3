function b = isnumber(str)

if ~ischar(str)
    b = false;
    return;
end
if isempty(str)
    b = false;
    return;
end

b = all( (str>='0' & str<='9') | (str =='e') | (str=='-' | str=='+' | str=='.' | str == ' '));

