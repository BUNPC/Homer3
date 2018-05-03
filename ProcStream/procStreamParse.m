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
nFunc           = 0 ;
funcName        = {};
funcNameUI      = {};
funcArgOut      = {};
funcArgIn       = {};
nFuncParam      = 0 ;
nFuncParamVar   = 0 ;
funcParam       = {};
funcParamFormat = {};
funcParamVal    = {};

nstr = length(C);
nfunc = 0;
flag = 0;
for ii=1:nstr
    if flag==0 || C{ii}(1)=='@'
        if C{ii}=='%'
            flag = 999;
        elseif C{ii}=='@'
            nfunc = nfunc + 1;
            
            k = findstr(C{ii+1},',');
            if ~isempty(k)
                funcName{nfunc} = C{ii+1}(1:k-1);
                funcNameUI{nfunc} = C{ii+1}(k+1:end);
                k = findstr(funcNameUI{nfunc},'_');
                funcNameUI{nfunc}(k)=' ';
            else
                funcName{nfunc} = C{ii+1};
                funcNameUI{nfunc} = funcName{nfunc};               
            end
            funcArgOut{nfunc} = C{ii+2};
            funcArgIn{nfunc} = C{ii+3};
            nFuncParam(nfunc) = 0;
            nFuncParamVar(nfunc) = 0;
            funcParam{nfunc} = [];
            funcParamFormat{nfunc} = [];
            funcParamVal{nfunc} = [];
            flag = 3;
        else
            if(C{ii} == '*')
                if exist('externVars','var') & ~isempty(externVars)
                    % We're about to call the function to find out it's parameter list. 
                    % Before calling it we need to get the input arguments from the 
                    % external variables list.
                    argIn = procStreamParseArgsIn(funcArgIn{nfunc});
                    for ii = 1:length(argIn)
                        if ~exist(argIn{ii},'var')
                            eval(sprintf('%s = externVars.%s;',argIn{ii},argIn{ii}));
                        end
                    end                
                    eval(sprintf('%s = %s%s);',funcArgOut{nfunc},funcName{nfunc},funcArgIn{nfunc}));
                    nFuncParam(nfunc) = nFuncParam0;       
                    funcParam{nfunc} = funcParam0;
                    funcParamFormat{nfunc} = funcParamFormat0;
                    funcParamVal{nfunc} = funcParamVal0;
                    for jj=1:nFuncParam(nfunc)
                        eval( sprintf('procParam(1).%s_%s = funcParamVal{nfunc}{jj};',funcName{nfunc},funcParam{nfunc}{jj}) );
                    end
                end
                nFuncParamVar(nfunc) = 1;
            elseif(C{ii} ~= '*') 
                nFuncParam(nfunc) = nFuncParam(nfunc) + 1;
                funcParam{nfunc}{nFuncParam(nfunc)} = C{ii};

                for jj = 1:length(C{ii+1})
                    if C{ii+1}(jj)=='_'
                        C{ii+1}(jj) = ' ';
                    end
                end
                funcParamFormat{nfunc}{nFuncParam(nfunc)} = C{ii+1};
                
                for jj = 1:length(C{ii+2})
                    if C{ii+2}(jj)=='_'
                        C{ii+2}(jj) = ' ';
                    end
                end
                val = str2num(C{ii+2});
                funcParamVal{nfunc}{nFuncParam(nfunc)} = val;    
                if(C{ii} ~= '*')
                    eval( sprintf('procParam(1).%s_%s = val;',funcName{nfunc},funcParam{nfunc}{nFuncParam(nfunc)}) );
                end
                nFuncParamVar(nfunc) = 0;
            end
            flag = 2;
        end
    else
        flag = flag - 1;
    end
end
procFunc.nFunc           = nfunc;
procFunc.funcName        = funcName;
procFunc.funcNameUI      = funcNameUI;
procFunc.funcArgOut      = funcArgOut;
procFunc.funcArgIn       = funcArgIn;
procFunc.nFuncParam      = nFuncParam;
procFunc.nFuncParamVar   = nFuncParamVar;
procFunc.funcParam       = funcParam;
procFunc.funcParamFormat = funcParamFormat;
procFunc.funcParamVal    = funcParamVal;

