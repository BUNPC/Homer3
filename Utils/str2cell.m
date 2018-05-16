function C = str2cell(S)

% Convert a single string with a bunch of newlines into a cell array of
% lines strings

C = {};
k = find(S == sprintf('\n'));
if isempty(k)
    C{1} = S;
    return;
end

k = [0,k];
for ii=2:length(k)
    C{ii-1,1} = strtrim(S( k(ii-1)+1:k(ii)-1 ));
end

