function [errflags, iReg] = procStreamErrCheck(varargin)

errflags = [];
iReg     = [];

procInput = ProcInputClass();
switch(class(varargin{1}))
    case 'ProcInputClass'
        procInput = varargin{1};
        type      = varargin{2};
    case {'GroupClass', 'SubjClass', 'RunClass'}
        procInput = varargin{1}.procStream.input;
        type      = class(varargin{1});
    otherwise
        return;
    end

func = procInput.func;
if isempty(func)
    return
end

% Build func database of registered functions
funcReg = procStreamReg2ProcFunc(type);

% Search for procFun functions in funcStrReg
errflags = ones(length(func),1);
iReg = zeros(length(func),1);
MATCH=1;
for ii=1:length(func)
    score=[0];
    kk=1;
    for jj=1:length(funcReg)
        if strcmp(func(ii).name, funcReg(jj).name)

            f1 = func(ii);
            f2 = funcReg(jj);

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

