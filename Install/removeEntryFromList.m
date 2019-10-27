function list = removeEntryFromList(name, list)

temp = strfind(list, name);
k=[];
for ii=1:length(temp)
    if ~isempty(temp{ii})
        k=ii;
    end
end
list(k) = [];

