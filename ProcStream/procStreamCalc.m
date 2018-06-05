
% Initialize output struct
procResult = InitProcResult();
procInput = procElem.procInput;

% loop over functions
paramOut = {};
fcallList = {};
hwait = waitbar(0, 'Processing...' );
for iFunc = 1:length(procInput.procFunc)
    
    waitbar( iFunc/length(procInput.procFunc), hwait, sprintf('Processing... %s', procInput.procFunc(iFunc).funcName) );
    
    % Extract input arguments from procElem
    argIn = procStreamParseArgsIn(procInput.procFunc(iFunc).funcArgIn);
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isproperty(procElem,argIn{ii})
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
    for iP = 1:procInput.procFunc(iFunc).nFuncParam
        if ~procInput.procFunc(iFunc).nFuncParamVar
            p{iP} = procInput.procFunc(iFunc).funcParamVal{iP};
        else
            p{iP}.name = procInput.procFunc(iFunc).funcParam{iP};
            p{iP}.val = procInput.procFunc(iFunc).funcParamVal{iP};
        end
        if length(procInput.procFunc(iFunc).funcArgIn)==1 & iP==1
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
    sargout = procInput.procFunc(iFunc).funcArgOut;
    for ii=1:length(procInput.procFunc(iFunc).funcArgOut)
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end
    
    % call function
    fcall = sprintf('%s = %s%s%s);', sargout, procInput.procFunc(iFunc).funcName, procInput.procFunc(iFunc).funcArgIn, sargin);

    try
        eval( fcall );
    catch ME
        msg = sprintf('Function %s generated error at line %d: %s', procInput.procFunc(iFunc).funcName, ME.stack(1).line, ME.message);
        menu(msg,'OK');
        close(hwait);
        assert(logical(0), msg);
    end

    fcallList{end+1} = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc(iFunc).funcName, ...
        procInput.procFunc(iFunc).funcArgIn, sarginVal );
    
    % parse output parameters
    foos = procInput.procFunc(iFunc).funcArgOut;

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

