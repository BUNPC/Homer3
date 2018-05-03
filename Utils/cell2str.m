function str = cell2str(c)

str = '';
for ii=1:length(c)       
    if isempty(str)
        str = sprintf(c{ii});
    else
        str = [str, ' ', sprintf(c{ii})];
    end
end

