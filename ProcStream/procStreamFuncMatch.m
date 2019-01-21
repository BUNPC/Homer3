function score = procStreamFuncMatch(f1,f2)

f1.argIn = procStreamParseArgsIn(f1.argIn);
f2.argIn = procStreamParseArgsIn(f2.argIn);
f1.argOut = procStreamParseArgsOut(f1.argOut);
f2.argOut = procStreamParseArgsOut(f2.argOut);

f1.nArgIn = length(f1.argIn);
f2.nArgIn = length(f2.argIn);
f1.nArgOut = length(f1.argOut);
f2.nArgOut = length(f2.argOut);

score = 0;
if ~f1.nParamVar && ~f2.nParamVar
    score_max = f1.nArgIn + f1.nArgOut + f1.nParam + ...
                f2.nArgIn + f2.nArgOut + f2.nParam;
elseif f1.nParamVar && f2.nParamVar
    score_max = f1.nArgIn + f1.nArgOut + ...
                f2.nArgIn + f2.nArgOut;
else
    score = 0;
end


% argIn
for i=1:min(f1.nArgIn,f2.nArgIn)
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
for i=1:min(f1.nArgOut,f2.nArgOut)
    if strcmp(f1.argOut{i},f2.argOut{i})
        score=score+2;
    end
end

score = score/score_max;

