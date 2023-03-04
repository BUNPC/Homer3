function verstr = versionnum2str(vernum)
verstr = '';
for ii = 1:length(vernum)
    if isempty(verstr)
        verstr = num2str(vernum(ii));
    else
        verstr = sprintf('%s.%s', verstr, num2str(vernum(ii)));
    end
end

