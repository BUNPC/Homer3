function [errflags iReg procInputReg] = procStreamErrCheckRun(procInput, run)

errflags = [];
iReg     = [];
procInputReg = [];
procFunc = procInput.procFunc;
if isempty(procFunc)
    return
end

% Build func database of registered functions
procStreamRegStr = procStreamReg(run);
for ii=1:length(procStreamRegStr)
    procInputReg = procStreamParse(procStreamRegStr{ii}, run);
    procFuncReg.funcName{ii}        = procInputReg.procFunc.funcName{1};
    procFuncReg.funcArgOut{ii}      = procInputReg.procFunc.funcArgOut{1};
    procFuncReg.funcArgIn{ii}       = procInputReg.procFunc.funcArgIn{1};
    procFuncReg.nFuncParam(ii)      = procInputReg.procFunc.nFuncParam(1);
    procFuncReg.nFuncParamVar(ii)   = procInputReg.procFunc.nFuncParamVar(1);
    procFuncReg.funcParam{ii}       = procInputReg.procFunc.funcParam{1};
    procFuncReg.funcParamFormat{ii} = procInputReg.procFunc.funcParamFormat{1};
    procFuncReg.funcParamVal{ii}    = procInputReg.procFunc.funcParamVal{1};
    fields = fieldnames(procInputReg.procParam);
    for jj=1:length(fields)
        eval(sprintf('procParamReg.%s = procInputReg.procParam.%s;',fields{jj},fields{jj}));
    end
end
procFuncReg.nFunc = ii;
procInputReg.procFunc = procFuncReg;
procInputReg.procParam = procParamReg;

% Search for procFun functions in procFuncStrReg
errflags = ones(procFunc.nFunc,1);
iReg = zeros(procFunc.nFunc,1);
MATCH=1;
for ii=1:procFunc.nFunc
    score=[0];
    kk=1;
    for jj=1:procInputReg.procFunc.nFunc
        if strcmp(procFunc.funcName{ii},procInputReg.procFunc.funcName{jj})

            f1.funcName        = procFunc.funcName{ii};
            f1.funcArgOut      = procFunc.funcArgOut{ii};
            f1.funcArgIn       = procFunc.funcArgIn{ii}; 
            f1.nFuncParam      = procFunc.nFuncParam(ii);
            f1.nFuncParamVar   = procFunc.nFuncParamVar(ii);
            f1.funcParam       = procFunc.funcParam{ii};
            f1.funcParamFormat = procFunc.funcParamFormat{ii};

            f2.funcName        = procInputReg.procFunc.funcName{jj};
            f2.funcArgOut      = procInputReg.procFunc.funcArgOut{jj};
            f2.funcArgIn       = procInputReg.procFunc.funcArgIn{jj}; 
            f2.nFuncParam      = procInputReg.procFunc.nFuncParam(jj);
            f2.nFuncParamVar   = procInputReg.procFunc.nFuncParamVar(jj);
            f2.funcParam       = procInputReg.procFunc.funcParam{jj};
            f2.funcParamFormat = procInputReg.procFunc.funcParamFormat{jj};

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

