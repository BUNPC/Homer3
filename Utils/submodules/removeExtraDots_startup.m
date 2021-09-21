function pname = removeExtraDots_startup(pname)
k = cell(4,3);

% Case 1:
k{1,1} = strfind(pname, '/./');
k{2,1} = strfind(pname, '/.\');
k{3,1} = strfind(pname, '\.\');
k{4,1} = strfind(pname, '\./');
for ii = 1:length(k(:,1))
    for jj = length(k{ii,1}):-1:1
        pname(k{ii,1}(jj)+1:k{ii,1}(jj)+2) = '';
    end
end

% Case 2:
k{1,2} = strfind(pname, '/.');
k{2,2} = strfind(pname, '\.');
for ii = 1:length(k(:,2))
    if ~isempty(k{ii,2})
        if k{ii,2}+1<length(pname)
            continue
        end
        pname(k{ii,2}+1) = '';
    end
end


