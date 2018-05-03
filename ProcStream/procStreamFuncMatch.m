function score = procStreamFuncMatch(f1,f2)

f1.funcArgIn = procStreamParseArgsIn(f1.funcArgIn);
f2.funcArgIn = procStreamParseArgsIn(f2.funcArgIn);
f1.funcArgOut = procStreamParseArgsOut(f1.funcArgOut);
f2.funcArgOut = procStreamParseArgsOut(f2.funcArgOut);

f1.nFuncArgIn = length(f1.funcArgIn);
f2.nFuncArgIn = length(f2.funcArgIn);
f1.nFuncArgOut = length(f1.funcArgOut);
f2.nFuncArgOut = length(f2.funcArgOut);

score = 0;
if ~f1.nFuncParamVar && ~f2.nFuncParamVar
    score_max = f1.nFuncArgIn + f1.nFuncArgOut + f1.nFuncParam + ...
                f2.nFuncArgIn + f2.nFuncArgOut + f2.nFuncParam;
elseif f1.nFuncParamVar && f2.nFuncParamVar
    score_max = f1.nFuncArgIn + f1.nFuncArgOut + ...
                f2.nFuncArgIn + f2.nFuncArgOut;
else
    score = 0;
end


% funcArgIn
for i=1:min(f1.nFuncArgIn,f2.nFuncArgIn)
    if strcmp(f1.funcArgIn{i},f2.funcArgIn{i})
        score=score+2;
    end
end


% funcParam
if ~f1.nFuncParamVar && ~f2.nFuncParamVar
    for i=1:min(f1.nFuncParam,f2.nFuncParam)
        if strcmp(f1.funcParam{i},f2.funcParam{i})
            score=score+2;
        end
    end
end


% funcArgOut
for i=1:min(f1.nFuncArgOut,f2.nFuncArgOut)
    if strcmp(f1.funcArgOut{i},f2.funcArgOut{i})
        score=score+2;
    end
end

score = score/score_max;

