function n = versionstr2num(s)
n = 0;
c = str2cell(s,'.');
m = length(c);
b = 100;
for ii = 1:length(c)
    n = n + (str2num(c{ii}) * b^(m-ii));
end

