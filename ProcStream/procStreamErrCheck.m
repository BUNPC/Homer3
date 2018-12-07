function [errflags, iReg] = procStreamErrCheck(varargin)

errflags = [];
iReg     = [];

procInput = ProcInputClass();
switch(class(varargin{1}))
    case 'ProcInputClass'
        procInput = varargin{1};
        type      = varargin{2};
    case {'GroupClass', 'SubjClass', 'RunClass'}
        procInput = varargin{1}.procInput;
        type      = class(varargin{1});
    otherwise
        return;
    end

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

