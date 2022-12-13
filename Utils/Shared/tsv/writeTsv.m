function writeTsv(filename, tsv, options)
global logger

if ~exist('filename', 'var')
    filename = '';
end
if ~exist('options', 'var')
    options = '';
end

if optionExists(options, logger)
    logger = InitLogger(logger);
    logger.Write('Exporting stim  to  %s\n', filename);
else
    fprintf('Exporting stim  to  %s\n', filename);    
end

fid = fopen(filename, 'wt');
for ii = 1:size(tsv,1)
    line = '';
    for jj = 1:size(tsv,2)
        if isnumeric(tsv{ii,jj})
            item = num2str(tsv{ii,jj});
        else
            item = tsv{ii,jj};
        end
        if isempty(line)
            line = sprintf('%s', item);
        else
            line = sprintf('%s\t%s', line, item);
        end
    end
    fprintf(fid, '%s\n', line);
end
fclose(fid);

