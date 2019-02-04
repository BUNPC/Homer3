classdef ProcStreamClass
    
    properties
        input
        output
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcStreamClass()
            obj.input = ProcInputClass();
            obj.output = ProcResultClass();
        end
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and output) from
        % obj2 to obj
        % ----------------------------------------------------------------------------------
        function Calc(obj)
            
            DEBUG = 0;
            
            % loop over functions
            nFcall = obj.input.GetFuncCallNum();
            paramOut = {};
            hwait = waitbar(0, 'Processing...' );
            for iFcall = 1:nFcall
                waitbar( iFcall/nFcall, hwait, sprintf('Processing... %s', obj.input.GetFcallNamePrettyPrint(iFcall)) );
                
                % Parse obj.input arguments
                argIn = obj.input.GetInputArgs(iFcall);
                for ii = 1:length(argIn)
                    if ~exist(argIn{ii},'var')
                        if ~obj.input.FindVar(argIn{ii})
                            continue;
                        end
                        eval(sprintf('%s = obj.input.GetVar(''%s'');', argIn{ii}, argIn{ii}));
                    end
                end
                
                % Parse obj.input parameters
                [sargin, p] = obj.input.ParseInputParams(iFcall);
                
                % Parse obj.input output arguments
                sargout = obj.input.ParseOutputArgs(iFcall);
                
                % call function
                fcall = sprintf('%s = %s%s%s);', sargout, obj.input.GetFuncCallName(iFcall), obj.input.fcalls(iFcall).argIn, sargin);
                if DEBUG
                    fprintf('%s\n', fcall);
                end
                try
                    eval( fcall );
                catch ME
                    msg = sprintf('Function %s generated error at line %d: %s', obj.input.fcalls(iFcall).name, ME.stack(1).line, ME.message);
                    menu(msg,'OK');
                    close(hwait);
                    assert(false, msg);
                end
                
                %%%% Parse output parameters
                
                % remove '[', ']', and ','
                foos = obj.input.fcalls(iFcall).argOut;
                for ii=1:length(foos)
                    if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
                        foos(ii) = ' ';
                    end
                end
                
                % get parameters for Output to obj.output
                lst = strfind(foos,' ');
                lst = [0, lst, length(foos)+1];
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
                if eval( sprintf('isproperty(obj.output, ''%s'');', paramOut{ii}) )
                    eval( sprintf('obj.output.%s = %s;', paramOut{ii}, paramOut{ii}) );
                else
                    eval( sprintf('obj.output.misc.%s = %s;', paramOut{ii}, paramOut{ii}) );
                end
            end
            obj.input.misc = [];
            close(hwait);
            
            if DEBUG
                fprintf('\n');
            end
            
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b=0;
            if isempty(obj.input)
                b=1;
                return;
            end
            b = obj.input.IsEmpty();
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = EditParam(obj, iFcall, iParam, val)
            str = '';
            if isempty(iFcall)
                return;
            end
            if isempty(iParam)
                return;
            end
            str = obj.input.EditParam(iFcall, iParam, val);
        end
        
    end        
end