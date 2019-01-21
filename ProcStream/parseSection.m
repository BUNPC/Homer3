function [func, param] = parseSection(C, externVars)

% Parse functions and parameters
% function call, param, param_format, param_value
% funcName{}, funcArgOut{}, funcArgIn{}, nFuncParam(), funcParam{nFunc}{nParam},
% funcParamFormat{nFunc}{nParam}, funcParamVal{nFunc}{nParam}()

param = struct([]);
func = repmat(InitProcFunc(),0,1);

nstr = length(C);
ifunc = 0;
flag = 0;
for ii=1:nstr
    if flag==0 || C{ii}(1)=='@'
        if C{ii}=='%'
            flag = 999;
        elseif C{ii}=='@'
            ifunc = ifunc+1;
            
            k = findstr(C{ii+1},',');
            func(ifunc) = InitProcFunc();
            if ~isempty(k)
                func(ifunc).funcName = C{ii+1}(1:k-1);
                func(ifunc).funcNameUI = C{ii+1}(k+1:end);
                k = findstr(func(ifunc).funcNameUI,'_');
                func(ifunc).funcNameUI(k)=' ';
            else
                func(ifunc).funcName = C{ii+1};
                func(ifunc).funcNameUI = func(ifunc).funcName;
            end
            func(ifunc).funcArgOut = C{ii+2};
            func(ifunc).funcArgIn = C{ii+3};
            flag = 3;
        else
            if(C{ii} == '*')
                if exist('externVars','var') & ~isempty(externVars) & isstruct(externVars)
                    % We're about to call the function to find out it's parameter list. 
                    % Before calling it we need to get the input arguments from the 
                    % external variables list.
                    argIn = procStreamParseArgsIn(func(ifunc).funcArgIn);
                    for ii = 1:length(argIn)
                        if ~exist(argIn{ii},'var')
                            eval(sprintf('%s = externVars.%s;',argIn{ii},argIn{ii}));
                        end
                    end                
                    eval(sprintf('%s = %s%s);',func(ifunc).funcArgOut, func(ifunc).funcName, func(ifunc).funcArgIn));
                    func(ifunc).nFuncParam = nFuncParam0;       
                    func(ifunc).funcParam = funcParam0;
                    func(ifunc).funcParamFormat = funcParamFormat0;
                    func(ifunc).funcParamVal = funcParamVal0;
                    for jj=1:func(ifunc).nFuncParam
                        eval( sprintf('param(1).%s_%s = func(ifunc).funcParamVal{jj};', func(ifunc).funcName, func(ifunc).funcParam{jj}) );
                    end
                end
                func(ifunc).nFuncParamVar = 1;
            elseif(C{ii} ~= '*') 
                func(ifunc).nFuncParam = func(ifunc).nFuncParam + 1;
                func(ifunc).funcParam{func(ifunc).nFuncParam} = C{ii};

                for jj = 1:length(C{ii+1})
                    if C{ii+1}(jj)=='_'
                        C{ii+1}(jj) = ' ';
                    end
                end
                func(ifunc).funcParamFormat{func(ifunc).nFuncParam} = C{ii+1};
                
                for jj = 1:length(C{ii+2})
                    if C{ii+2}(jj)=='_'
                        C{ii+2}(jj) = ' ';
                    end
                end
                val = str2num(C{ii+2});
                func(ifunc).funcParamVal{func(ifunc).nFuncParam} = val;    
                if(C{ii} ~= '*')
                    eval( sprintf('param(1).%s_%s = val;',func(ifunc).funcName, func(ifunc).funcParam{func(ifunc).nFuncParam}) );
                end
                func(ifunc).nFuncParamVar = 0;
            end
            flag = 2;
        end
    else
        flag = flag-1;
    end
end


