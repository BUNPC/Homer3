function userdata = InitUserdata(s, t)

[lstR,lstC] = find(abs(s)==1);
[lstR,k] = sort(lstR);
data = repmat({0,''},length(lstR),1);
for ii=1:length(lstR)
    data{ii,1} = t(lstR(ii));
end
cnames={'1'};
cwidth={100};
ceditable=logical([1]);


userdata.data = data;
userdata.cnames = cnames;
userdata.cwidth = cwidth;
userdata.ceditable = ceditable;
