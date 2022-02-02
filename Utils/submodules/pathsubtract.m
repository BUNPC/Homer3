function diff = pathsubtract(p2, p1)
diff = '';
p1 = filesepStandard(p1, 'full');
p2 = filesepStandard(p2, 'full');

k = strfind(p2, p1);
diff = p2(k+length(p1):end);

