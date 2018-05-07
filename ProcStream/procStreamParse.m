function [procInput, err, errstr] = procStreamParse(fid_or_str, procElem)

%
% Processing stream config file parser. This function handles
% group, subj and run processing stream parameters
%

procInput = [];
err=0;
errstr='';

if ~exist('procElem','var')
    procElem = [];
end

[G, S, R] = procStreamPreParse(fid_or_str, procElem);

switch(procElem.type)
case 'group'
    % generate default contents for group section if there's no % group header. 
    % This can happen if homer2-style config file was read    
    if isempty(G) | ~strcmpi(deblank([G{1},G{2}]), '%group')
        [~, str] = procStreamDefaultFileGroup(parseSection(R));
        foo = textscan(str, '%s');
        G = foo{1};
	end
    procInput = InitProcInputGroup();    
    [procInput.procFunc, procInput.procParam] = parseSection(G, procElem);
case 'subj'
    % generate default contents for subject section if scanned contents is
    % from a file and there's no % subj header. This can happen if
    % homer2-style config file was loaded
    if isempty(S) | ~strcmpi(deblank([S{1},S{2}]), '%subj')
        [~, str] = procStreamDefaultFileSubj(parseSection(R));
        foo = textscan(str, '%s');
        S = foo{1};
    end
    procInput = InitProcInputSubj();
    [procInput.procFunc, procInput.procParam] = parseSection(S, procElem);
case 'run'
    procInput = InitProcInputRun();
    [procInput.procFunc, procInput.procParam] = parseSection(R, procElem);
end



% ---------------------------------------------------------------------
function [procFunc, procParam] = parseSection(C, externVars)

% Parse functions and parameters
% function call, param, param_format, param_value
% funcName{}, funcArgOut{}, funcArgIn{}, nFuncParam(), funcParam{nFunc}{nParam},
% funcParamFormat{nFunc}{nParam}, funcParamVal{nFunc}{nParam}()

procParam = struct([]);
procFunc = repmat(InitProcFunc(),0,3);

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


