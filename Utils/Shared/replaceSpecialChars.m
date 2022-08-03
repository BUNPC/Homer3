function s2 = replaceSpecialChars(s)
s2 = '';
if ~ischar(s)
    s2 = s;
    return;
end
[c, k] = str2cell(s, '''', 'keepblanks');
for ii = 1:length(c)
    if isempty(s2)
        s2 = c{ii};
    else
        s2 = sprintf('"%s" %s', s2, c{ii});
    end
end

% Remove any newlines or carriage returns from middle of string ONLY IF
% there are quotes to be managed
if ~isempty(k)
    k1 = find(s2==10);
    k2 = find(s2==13);
    m = [k1,k2];
    j = find(m == length(s2));
    m(j) = [];
    s2(m) = '';
end