function ndim = getNdim(m)

s = size(m);
s(s==1) = [];
ndim = length(s);
