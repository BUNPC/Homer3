function procStreamCalc(obj)

% Initialize output struct
obj.procStream.output = ProcResultClass();
input = obj.procStream.input;

% loop over functions
nFunc = length(input.func);
paramOut = {};
hwait = waitbar(0, 'Processing...' );

for iFunc = 1:nFunc
    
    waitbar( iFunc/length(input.func), hwait, sprintf('Processing... %s', input.func(iFunc).name) );
    
    % Extract input arguments from procElem
    argIn = procStreamParseArgsIn(input.func(iFunc).argIn);
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isproperty(obj.procStream.input, argIn{ii})
                eval(sprintf('%s = obj.procStream.input.%s;', argIn{ii}, argIn{ii}));
            elseif isproperty(obj.procStream.input.misc, argIn{ii})
                eval(sprintf('%s = obj.procStream.input.misc.%s;', argIn{ii}, argIn{ii}));
            else
                eval(sprintf('%s = obj.FindVar(''%s'');', argIn{ii}, argIn{ii}));
            end
        end
    end

    % parse input parameters
    p = [];
    sargin = '';
    sarginVal = '';
    for iP = 1:input.func(iFunc).nParam
        if ~input.func(iFunc).nParamVar
            p{iP} = input.func(iFunc).paramVal{iP};
        else
            p{iP}.name = input.func(iFunc).param{iP};
            p{iP}.val = input.func(iFunc).paramVal{iP};
        end
        if length(input.func(iFunc).argIn)==1 & iP==1
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
    sargout = input.func(iFunc).argOut;
    for ii=1:length(input.func(iFunc).argOut)
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end
    
    % call function
    fcall = sprintf('%s = %s%s%s);', sargout, input.func(iFunc).name, input.func(iFunc).argIn, sargin);
    try
        eval( fcall );
    catch ME
        msg = sprintf('Function %s generated error at line %d: %s', input.func(iFunc).name, ME.stack(1).line, ME.message);
        menu(msg,'OK');
        close(hwait);
        assert(false, msg);
    end
    
    % parse output parameters
    foos = input.func(iFunc).argOut;

    % remove '[', ']', and ','
    for ii=1:length(foos)
        if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
            foos(ii) = ' ';
        end
    end
    
    % get parameters for Output to obj.output
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

% Copy paramOut to output
for ii=1:length(paramOut)
    if eval( sprintf('isproperty(obj.procStream.output, ''%s'');', paramOut{ii}) );
	    eval( sprintf('obj.procStream.output.%s = %s;',paramOut{ii}, paramOut{ii}) );
    else
	    eval( sprintf('obj.procStream.output.misc.%s = %s;',paramOut{ii}, paramOut{ii}) );        
    end
end

obj.procStream.input.misc = [];
close(hwait)

