function args = procStreamParseArgsIn(argsStr)

args={};

if argsStr(1) ~= '('
    return;
end

j=2;
k=[findstr(argsStr,',') length(argsStr)+1];
for ii=1:length(k)
    args{ii}=argsStr(j:k(ii)-1);
    j=k(ii)+1;
end
