function [procInput filename] = GetProcInputDefaultSubj(subj, filename)

procInput = struct([]); 
if ~exist('filename','var') || isempty(filename)
    filename = '';
end

err1=0; err2=0;
if procStreamIsEmpty(subj.procInput)
    err1=1; err2=1;
else
    procInput = subj.procInput;
end


%%%%% Otherwise try loading procInput from a config file, but first 
%%%%% figure out the name of the config file
while ~all(~err1) || ~all(~err2)

    % Load Processing stream file
    if isempty(filename)
        
        [filename, pathname] = createDefaultConfigFile();
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput err1] = procStreamParse(fid, subj);
        fclose(fid);
        
    elseif ~isempty(filename)
        
        % Load procInput from config file
        fid = fopen(filename,'r');
        [procInput err1] = procStreamParse(fid, subj);   
        fclose(fid);
        
    else
        
        err1=0;
    
    end
    
    % Check loaded procInput for syntax and semantic errors
    if isempty(procInput.procFunc) && err1==0
        ch = menu('Warning: config file is empty.','Okay');
    elseif err1==1
        ch = menu('Syntax error in config file.','Okay');
    end

    err2 = procStreamErrCheckSubj(procInput, subj);
 
    if ~all(err2==0)
        filename='';
    end
end

