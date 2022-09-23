function diff = pathsubtract(p2_0, p1_0, options)
if ~exist('options','var')
    options = '';
end
if optionExists_startup(options, 'nochange')
    option = '';
else
    option = 'full';
end
p1 = filesepStandard_startup(p1_0, option);
p2 = filesepStandard_startup(p2_0, option);
if isempty(p1)
    p1 = p1_0;
end
if isempty(p2)
    p2 = p2_0;
end
k = strfind(p2, p1);
if ~isempty(k) && k(1)==1
    diff = p2(k(1)+length(p1):end);
elseif ~isempty(k)
    diff = p2(1:k(1)-1);
else
    diff = '';
end
