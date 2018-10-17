function str2 = sprintf_s(str)

str2='';
kk=1;
for ii=1:length(str)
    if str(ii)=='_'
        str2(kk) = '\';
        kk=kk+1;
    end
    str2(kk) = str(ii);
    kk=kk+1;
end

