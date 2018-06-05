function [procResult procInput err fcallList] = CalcProcStreamRun(run,flagNoRun)

if ~exist('flagNoRun')
    flagNoRun = 0;
end

% Initialize output struct
procResult = initProcResultStruct('run');
[err procInput] = procStreamHasErrors(run);
if err
    return;
end


% loop over functions
paramOut = {};
fcallList = {};
hwait = waitbar(0, 'Processing...' );
for iFunc = 1:procInput.procFunc.nFunc
    
    waitbar( iFunc/procInput.procFunc.nFunc, hwait, sprintf('Processing... %s',procInput.procFunc(iFunc).funcName) );
    
    % Extract input arguments from run
    argIn = parseProcessFuncArgsIn(procInput.procFunc(iFunc).funcArgIn);
    for ii = 1:length(argIn)
        if ~exist(argIn{ii},'var')
            if isproperty(run,argIn{ii})
                eval(sprintf('%s = run.%s;',argIn{ii},argIn{ii}));
            else
                eval(sprintf('%s = [];',argIn{ii}));  % if variable doesn't exist and not in run then make it empty DAB 11/8/11
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
    fcall = sprintf( '%s = %s%s%s);', sargout, ...
        procInput.procFunc(iFunc).funcName, ...
        procInput.procFunc(iFunc).funcArgIn, sargin );
    if flagNoRun==0
        eval( fcall );
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
    % get parameters for Output to run.procResult
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

% Return if flagNoRun 
% before results are saved back to run
if flagNoRun==1
    close(hwait)
    return;
end

% Copy paramOut to procResult
for ii=1:length(paramOut)
    eval( sprintf('procResult.%s = %s;',paramOut{ii}, paramOut{ii}) );
end

% Set changeFlag to show that procResult is consistent with 
% procInput for this run
procInput.changeFlag = 0;

% Save procResult and the procInput that generated it, to the run's 
% .nirs file
% Get input parameters for saving to .nirs file
strLst = '''procResult'',procResult,';
strLst = [strLst '''procInput'',procInput,'];
strLst = [strLst '''SD'',run.SD,'];
strLst = [strLst '''s'',run.s,'];
strLst = [strLst '''tIncMan'',run.tIncMan,'];
strLst = [strLst '''userdata'',run.userdata'];

eval(sprintf('SaveDataToRun(run.name, %s)', strLst) );
close(hwait)



% ------------------------------------------------------------------
function [B procInput]=procStreamHasErrors(run)

procInput = run.procInput;
B=0;
err = EasyNIRS_ProcessOpt_ErrorCheck(run.procInput.procFunc,run);
if ~all(~err)
    i=find(err==1);
    str1 = 'Error in procInput\n\n';
    for j=1:length(i)
        str2 = sprintf('%s%s',run.procInput.procFunc.funcName{i(j)},'\n');
        str1 = strcat(str1,str2);
    end
    str1 = strcat(str1,'\n');
    str1 = strcat(str1,'Load another processing stream?');
    ch = menu( sprintf(str1), 'Yes','No');
    if ch==1
        procInput=EasyNIRS_ProcessOpt_Init();
    end
    B=1;
end
