function s2 = replaceSpecialChars(s)
s2 = '';
if ~ischar(s)
    s2 = s;
    return;
end
[c, k] = str2cell(s, '''');
for ii = 1:length(c)
    if isempty(s2)
        s2 = c{ii};
    else
        s2 = sprintf('%s''''%s', s2, c{ii});
    end
end     
