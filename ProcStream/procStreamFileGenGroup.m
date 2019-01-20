function procStreamFileGenGroup(filepath)

% Generates default processOpt.cfg file. 
% Note that fprintf outputs formatted text where some characters 
% are special characters - such as '%'. In order to write a 
% literal '%' you need to type '%%' in fprintf argument string 
% (2nd argument).
% 
% $Log: %
% 

if ischar(filepath)
    slashes = [findstr(filepath,'/') findstr(filepath,'\')];
    if(~isempty(slashes))
        filename = ['.' filepath(slashes(end):end)];
    end
    fid = fopen(filename,'a');
else
    fid = filepath;
end

contents = procStreamDefaultFileGroup();
for ii=1:length(contents)
    fprintf(fid, contents{ii});
end

if ischar(filepath)
    fclose(fid);
else
    fseek(fid,0,'bof');
end
