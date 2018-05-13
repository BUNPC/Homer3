function [procFunc, procParam] = parseSection(C, externVars)

% Parse functions and parameters
% function call, param, param_format, param_value
% funcName{}, funcArgOut{}, funcArgIn{}, nFuncParam(), funcParam{nFunc}{nParam},
% funcParamFormat{nFunc}{nParam}, funcParamVal{nFunc}{nParam}()

procParam = struct([]);
procFunc = repmat(InitProcFunc(),0,1);

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
            procFunc(ifunc) = InitProcFunc();
            if ~isempty(k)
                procFunc(ifunc).funcName = C{ii+1}(1:k-1);
                procFunc(ifunc).funcNameUI = C{ii+1}(k+1:end);
                k = findstr(procFunc(ifunc).funcNameUI,'_');
                procFunc(ifunc).funcNameUI(k)=' ';
            else
                procFunc(ifunc).funcName = C{ii+1};
                procFunc(ifunc).funcNameUI = procFunc(ifunc).funcName;
            end
            procFunc(ifunc).funcArgOut = C{ii+2};
            procFunc(ifunc).funcArgIn = C{ii+3};
            flag = 3;
        else
            if(C{ii} == '*')
                if exist('externVars','var') & ~isempty(externVars)
                    % We're about to call the function to find out it's parameter list. 
                    % Before calling it we need to get the input arguments from the 
                    % external variables list.
                    argIn = procStreamParseArgsIn(procFunc(ifunc).funcArgIn);
                    for ii = 1:length(argIn)
                        if ~exist(argIn{ii},'var')
                            eval(sprintf('%s = externVars.%s;',argIn{ii},argIn{ii}));
                        end
                    end                
                    eval(sprintf('%s = %s%s);',procFunc(ifunc).funcArgOut, procFunc(ifunc).funcName, procFunc(ifunc).funcArgIn));
                    procFunc(ifunc).nFuncParam = nFuncParam0;       
                    procFunc(ifunc).funcParam = funcParam0;
                    procFunc(ifunc).funcParamFormat = funcParamFormat0;
                    procFunc(ifunc).funcParamVal = funcParamVal0;
                    for jj=1:procFunc(ifunc).nFuncParam
                        eval( sprintf('procParam(1).%s_%s = procFunc(ifunc).funcParamVal{jj};', procFunc(ifunc).funcName, procFunc(ifunc).funcParam{jj}) );
                    end
                end
                procFunc(ifunc).nFuncParamVar = 1;
            elseif(C{ii} ~= '*') 
                procFunc(ifunc).nFuncParam = procFunc(ifunc).nFuncParam + 1;
                procFunc(ifunc).funcParam{procFunc(ifunc).nFuncParam} = C{ii};

                for jj = 1:length(C{ii+1})
                    if C{ii+1}(jj)=='_'
                        C{ii+1}(jj) = ' ';
                    end
                end
                procFunc(ifunc).funcParamFormat{procFunc(ifunc).nFuncParam} = C{ii+1};
                
                for jj = 1:length(C{ii+2})
                    if C{ii+2}(jj)=='_'
                        C{ii+2}(jj) = ' ';
                    end
                end
                val = str2num(C{ii+2});
                procFunc(ifunc).funcParamVal{procFunc(ifunc).nFuncParam} = val;    
                if(C{ii} ~= '*')
                    eval( sprintf('procParam(1).%s_%s = val;',procFunc(ifunc).funcName, procFunc(ifunc).funcParam{procFunc(ifunc).nFuncParam}) );
                end
                procFunc(ifunc).nFuncParamVar = 0;
            end
            flag = 2;
        end
    else
        flag = flag-1;
    end
end


