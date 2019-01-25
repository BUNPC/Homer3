function score = procStreamFuncMatch(f1,f2)

f1.argIn = procStreamParseArgsIn(f1.argIn);
f2.argIn = procStreamParseArgsIn(f2.argIn);
f1.argOut = procStreamParseArgsOut(f1.argOut);
f2.argOut = procStreamParseArgsOut(f2.argOut);

nArgIn1 = length(f1.argIn);
nArgIn2 = length(f2.argIn);
nArgOut1 = length(f1.argOut);
nArgOut2 = length(f2.argOut);

score = 0;
if ~f1.nParamVar && ~f2.nParamVar
    score_max = nArgIn1 + nArgOut1 + f1.nParam + ...
                nArgIn2 + nArgOut2 + f2.nParam;
elseif f1.nParamVar && f2.nParamVar
    score_max = nArgIn1 + nArgOut1 + ...
                nArgIn2 + nArgOut2;
else
    score = 0;
end

% argIn
for i=1:min(nArgIn1,nArgIn2)
    if strcmp(f1.argIn{i},f2.argIn{i})
        score=score+2;
    end
end

% param
if ~f1.nParamVar && ~f2.nParamVar
    for i=1:min(f1.nParam,f2.nParam)
        if strcmp(f1.param{i},f2.param{i})
            score=score+2;
        end
    end
end

% argOut
for i=1:min(nArgOut1,nArgOut2)
    if strcmp(f1.argOut{i},f2.argOut{i})
        score=score+2;
    end
end

score = score/score_max;

