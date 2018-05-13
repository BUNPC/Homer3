function [errflags, iReg, procInputReg] = procStreamErrCheckRun(procInput, run)

errflags = [];
iReg     = [];
procInputReg = [];
procFunc = procInput.procFunc;
if isempty(procFunc)
    return
end

% Build func database of registered functions
reg = procStreamReg(run);
for ii=1:length(reg)
    procInputReg = procStreamParse(reg{ii}{1}, run);
    procFuncReg(ii) = procInputReg.procFunc(1);
    fields = fieldnames(procInputReg.procParam);
    for jj=1:length(fields)
        eval(sprintf('procParamReg.%s = procInputReg.procParam.%s;',fields{jj},fields{jj}));
    end
end
procInputReg.procFunc = procFuncReg;
procInputReg.procParam = procParamReg;

% Search for procFun functions in procFuncStrReg
errflags = ones(length(procFunc),1);
iReg = zeros(length(procFunc),1);
MATCH=1;
for ii=1:length(procFunc)
    score=[0];
    kk=1;
    for jj=1:length(procInputReg.procFunc)
        if strcmp(procFunc(ii).funcName, procInputReg.procFunc(jj).funcName)

            f1 = procFunc(ii);
            f2 = procInputReg.procFunc(jj);

            score(kk) = procStreamFuncMatch(f1,f2);
            [p,maxscore_idx] = max(score);
            if score(kk)==MATCH

                errflags(ii) = 0;
                iReg(ii) = jj;

            elseif maxscore_idx==kk
                
                iReg(ii) = jj;

            end
            kk=kk+1;
        end
    end
end

