function [func, param] = parseSection(C)

% Parse functions and parameters
% function call, param, param_format, param_value
% name{}, argOut{}, argIn{}, nParam(), param{nFunc}{nParam},
% paramFormat{nFunc}{nParam}, paramVal{nFunc}{nParam}()

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
                func(ifunc).name = C{ii+1}(1:k-1);
                func(ifunc).nameUI = C{ii+1}(k+1:end);
                k = findstr(func(ifunc).nameUI,'_');
                func(ifunc).nameUI(k)=' ';
            else
                func(ifunc).name = C{ii+1};
                func(ifunc).nameUI = func(ifunc).name;
            end
            func(ifunc).argOut = C{ii+2};
            func(ifunc).argIn = C{ii+3};
            flag = 3;
        else
            if(C{ii} == '*')
                func(ifunc).nParamVar = 1;
            elseif(C{ii} ~= '*') 
                func(ifunc).nParam = func(ifunc).nParam + 1;
                func(ifunc).param{func(ifunc).nParam} = C{ii};

                for jj = 1:length(C{ii+1})
                    if C{ii+1}(jj)=='_'
                        C{ii+1}(jj) = ' ';
                    end
                end
                func(ifunc).paramFormat{func(ifunc).nParam} = C{ii+1};
                
                for jj = 1:length(C{ii+2})
                    if C{ii+2}(jj)=='_'
                        C{ii+2}(jj) = ' ';
                    end
                end
                val = str2num(C{ii+2});
                func(ifunc).paramVal{func(ifunc).nParam} = val;    
                if(C{ii} ~= '*')
                    eval( sprintf('param(1).%s_%s = val;',func(ifunc).name, func(ifunc).param{func(ifunc).nParam}) );
                end
                func(ifunc).nParamVar = 0;
            end
            flag = 2;
        end
    else
        flag = flag-1;
    end
end


