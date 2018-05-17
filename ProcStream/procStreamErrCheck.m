function [errflags, iReg] = procStreamErrCheck(argIn)

procInput = InitProcInput();
if isfield(argIn, 'procElem')
    type = argIn.procElem.type;
    procInput = argIn.procElem.procInput;
elseif isfield(argIn, 'procInput')
    type = argIn.type;
    procInput = argIn.procInput;
elseif isfield(argIn, 'procFunc')
    type = '';
    procInput = argIn;
end


errflags = [];
iReg     = [];

procFunc = procInput.procFunc;
if isempty(procFunc)
    return
end

% Build func database of registered functions
procFuncReg = procStreamReg2ProcFunc(type);

% Search for procFun functions in procFuncStrReg
errflags = ones(length(procFunc),1);
iReg = zeros(length(procFunc),1);
MATCH=1;
for ii=1:length(procFunc)
    score=[0];
    kk=1;
    for jj=1:length(procFuncReg)
        if strcmp(procFunc(ii).funcName, procFuncReg(jj).funcName)

            f1 = procFunc(ii);
            f2 = procFuncReg(jj);

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

