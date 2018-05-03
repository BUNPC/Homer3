function args = procStreamParseArgsOut(argsStr)

args={};
kk=1;
ii=1;
jj=1;
while ii<=length(argsStr)
    if argsStr(ii)=='#' || argsStr(ii)=='[' || argsStr(ii)==']'
        ii=ii+1;
        continue;
    end
    if argsStr(ii)==','
        kk=kk+1;
        ii=ii+1;
        jj=1;
        continue;
    end

    args{kk}(jj)=argsStr(ii);
    jj=jj+1;
    ii=ii+1;
end
