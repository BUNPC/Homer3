function [n0, n1] = versionstr2num(s)
n0 = 0;
if iscell(s)
    c = s;
else
	c = str2cell(s,'.');
end
n1 = zeros(1,length(c));
m = length(c);
b = 100;
for ii = 1:length(c)
    n0 = n0 + (str2num(c{ii}) * b^(m-ii));
    n1(1,ii) = str2num(c{ii});
end

