function [procInput, filename] = GetProcInputDefaultRun(run, filename)

procInput = struct([]); 
if ~exist('filename','var') || isempty(filename)
    filename = '';
end

err1=0; err2=0;
if procStreamIsEmpty(run.procInput)    
    err1=1; err2=1;
else
    procInput = run.procInput;
end


%%%%% Otherwise try loading procInput from a config file, but first 
%%%%% figure out the name of the config file
while ~all(~err1) || ~all(~err2)

    % Load Processing stream file
    if isempty(filename)
        
        [filename, ~] = createDefaultConfigFile();
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput, err1] = procStreamParse(fid, run);
        fclose(fid);
        
    elseif ~isempty(filename)
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput, err1] = procStreamParse(fid, run);   
        fclose(fid);
        
    else
        
        err1=0;
    
    end
    

    % Check loaded procInput for syntax and semantic errors
    if procStreamIsEmpty(procInput) && err1==0
        ch = menu('Warning: config file is empty.','Okay');
    elseif err1==1
        ch = menu('Syntax error in config file.','Okay');
    end

    [err2, iReg, procInputReg] = procStreamErrCheckRun(procInput, run);
    if ~all(~err2)
        i=find(err2==1);
        str1 = 'Error in functions\n\n';
        for j=1:length(i)
            str2 = sprintf('%s%s',procInput.procFunc.funcName{i(j)},'\n');
            str1 = strcat(str1,str2);
        end
        str1 = strcat(str1,'\n');
        str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
        ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
        if ch==1
            [procInput, err2] = procStreamFixErr(err2, procInput, run, iReg, procInputReg);            
        elseif ch==2
            filename = './processOpt_default.cfg';
            procStreamFileGen(filename);
            fid = fopen(filename,'r');
            procInput = procStreamParseRun(fid, run);
            fclose(fid);
            break;
        elseif ch==3
            return;
        end
    end
    filename = [];
end

