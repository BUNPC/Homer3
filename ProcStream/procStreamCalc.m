
% Initialize output struct
if strcmpi(procElem.type,'group')
    procResult = InitProcResultGroup();
elseif strcmpi(procElem.type,'subj')
    procResult = InitProcResultSubj();
elseif strcmpi(procElem.type,'run')
    procResult = InitProcResultRun();
end

procInput = procElem.procInput;

% loop over functions
paramOut = {};
fcallList = {};
hwait = waitbar(0, 'Processing...' );
for iFunc = 1:procInput.procFunc.nFunc
    
    waitbar( iFunc/procInput.procFunc.nFunc, hwait, sprintf('Processing... %s',procInput.procFunc.funcName{iFunc}) );
    
    % Extract input arguments from procElem
    argIn = procStreamParseArgsIn(procInput.procFunc.funcArgIn{iFunc});
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isfield(procElem,argIn{ii})
                eval(sprintf('%s = procElem.%s;',argIn{ii},argIn{ii}));
            else
                eval(sprintf('%s = [];',argIn{ii}));  % if variable doesn't exist and not in procElem then make it empty DAB 11/8/11
            end
        end
    end

    % parse input parameters
    p = [];
    sargin = '';
    sarginVal = '';
    for iP = 1:procInput.procFunc.nFuncParam(iFunc)
        if ~procInput.procFunc.nFuncParamVar(iFunc)
            p{iP} = procInput.procFunc.funcParamVal{iFunc}{iP};
        else
            p{iP}.name = procInput.procFunc.funcParam{iFunc}{iP};
            p{iP}.val = procInput.procFunc.funcParamVal{iFunc}{iP};
        end
        if length(procInput.procFunc.funcArgIn{iFunc})==1 & iP==1
            sargin = sprintf('%sp{%d}',sargin,iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s%s',sarginVal,num2str(p{iP}));
                else
                    sarginVal = sprintf('%s[%s]',sarginVal,num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s',sarginVal,p{iP});
            else
                sarginVal = sprintf('%s,[XXX]',sarginVal);
            end
        else
            sargin = sprintf('%s,p{%d}',sargin,iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s,%s',sarginVal,num2str(p{iP}));
                else
                    sarginVal = sprintf('%s,[%s]',sarginVal,num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s',sarginVal,p{iP});
            else
                sarginVal = sprintf('%s,[XXX]',sarginVal);
            end
        end
    end
    
    % set up output format
    sargout = procInput.procFunc.funcArgOut{iFunc};
    for ii=1:length(procInput.procFunc.funcArgOut{iFunc})
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end
    
    % call function
    fcall = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc.funcName{iFunc}, ...
        procInput.procFunc.funcArgIn{iFunc}, sargin );

    try
        eval( fcall );
    catch ME
        msg = sprintf('Function %s generated error at line %d: %s', procInput.procFunc.funcName{iFunc}, ME.stack(1).line, ME.message);
        menu(msg,'OK');
        close(hwait);
        assert(logical(0), msg);
    end

    fcallList{end+1} = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc.funcName{iFunc}, ...
        procInput.procFunc.funcArgIn{iFunc}, sarginVal );
    
    % parse output parameters
    foos = procInput.procFunc.funcArgOut{iFunc};

    % remove '[', ']', and ','
    for ii=1:length(foos)
        if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
            foos(ii) = ' ';
        end
    end
    
    % get parameters for Output to procElem.procResult
    lst = strfind(foos,' ');
    lst = [0 lst length(foos)+1];
    param = [];
    for ii=1:length(lst)-1
        foo2 = foos(lst(ii)+1:lst(ii+1)-1);
        lst2 = strmatch( foo2, paramOut, 'exact' );
        idx = strfind(foo2,'foo');
        if isempty(lst2) & (isempty(idx) || idx>1) & ~isempty(foo2)
            paramOut{end+1} = foo2;
        end
    end
    
end

% Copy paramOut to procResult
for ii=1:length(paramOut)
    eval( sprintf('procResult.%s = %s;',paramOut{ii}, paramOut{ii}) );
end

close(hwait)

