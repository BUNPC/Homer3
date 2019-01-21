function procStreamCalc(obj)

% Initialize output struct
obj.procResult = ProcResultClass();
procInput = obj.procInput;

% loop over functions
nFunc = length(procInput.func);
paramOut = {};
hwait = waitbar(0, 'Processing...' );

for iFunc = 1:nFunc
    
    waitbar( iFunc/length(procInput.func), hwait, sprintf('Processing... %s', procInput.func(iFunc).name) );
    
    % Extract input arguments from procElem
    argIn = procStreamParseArgsIn(procInput.func(iFunc).argIn);
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isproperty(obj.procInput, argIn{ii})
                eval(sprintf('%s = obj.procInput.%s;', argIn{ii}, argIn{ii}));
            elseif isproperty(obj.procInput.misc, argIn{ii})
                eval(sprintf('%s = obj.procInput.misc.%s;', argIn{ii}, argIn{ii}));
            else
                eval(sprintf('%s = obj.FindVar(''%s'');', argIn{ii}, argIn{ii}));
            end
        end
    end

    % parse input parameters
    p = [];
    sargin = '';
    sarginVal = '';
    for iP = 1:procInput.func(iFunc).nParam
        if ~procInput.func(iFunc).nParamVar
            p{iP} = procInput.func(iFunc).paramVal{iP};
        else
            p{iP}.name = procInput.func(iFunc).param{iP};
            p{iP}.val = procInput.func(iFunc).paramVal{iP};
        end
        if length(procInput.func(iFunc).argIn)==1 & iP==1
            sargin = sprintf('%sp{%d}', sargin, iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s%s', sarginVal, num2str(p{iP}));
                else
                    sarginVal = sprintf('%s[%s]', sarginVal, num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s', sarginVal, p{iP});
            else
                sarginVal = sprintf('%s,[XXX]', sarginVal);
            end
        else
            sargin = sprintf('%s,p{%d}', sargin, iP);
            if isnumeric(p{iP})
                if length(p{iP})==1
                    sarginVal = sprintf('%s,%s', sarginVal, num2str(p{iP}));
                else
                    sarginVal = sprintf('%s,[%s]', sarginVal, num2str(p{iP}));
                end
            elseif ~isstruct(p{iP})
                sarginVal = sprintf('%s,%s', sarginVal, p{iP});
            else
                sarginVal = sprintf('%s,[XXX]',sarginVal);
            end
        end
    end
    
    % set up output format
    sargout = procInput.func(iFunc).argOut;
    for ii=1:length(procInput.func(iFunc).argOut)
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end
    
    % call function
    fcall = sprintf('%s = %s%s%s);', sargout, procInput.func(iFunc).name, procInput.func(iFunc).argIn, sargin);

    try
        eval( fcall );
    catch ME
        msg = sprintf('Function %s generated error at line %d: %s', procInput.func(iFunc).name, ME.stack(1).line, ME.message);
        menu(msg,'OK');
        close(hwait);
        assert(false, msg);
    end
    
    % parse output parameters
    foos = procInput.func(iFunc).argOut;

    % remove '[', ']', and ','
    for ii=1:length(foos)
        if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
            foos(ii) = ' ';
        end
    end
    
    % get parameters for Output to obj.procResult
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
    if eval( sprintf('isproperty(obj.procResult, ''%s'');', paramOut{ii}) );
	    eval( sprintf('obj.procResult.%s = %s;',paramOut{ii}, paramOut{ii}) );
    else
	    eval( sprintf('obj.procResult.misc.%s = %s;',paramOut{ii}, paramOut{ii}) );        
    end
end

obj.procInput.misc = [];
close(hwait)

