function C = str2cell(str, delimiters)

if ~exist('delimiters','var')
    delimiters{1} = sprintf('\n');
elseif ~iscell(delimiters)
    foo{1} = delimiters;
    delimiters = foo;
end

% Get indices of all the delimiters
k=1;
for kk=1:length(delimiters)
    k = [k, find(str==delimiters{kk})];
end
k = [k, length(str)];

% 
C = cell(length(k)-1,1);
for ii=1:length(C)
    if ii==1 && ii==length(C)
        C{ii} = str(k(ii):k(ii+1));
    elseif ii==1
        C{ii} = str(k(ii):k(ii+1)-1);
    elseif ii==length(C)
        C{ii} = str(k(ii)+1:k(ii+1));
    else
        C{ii} = str(k(ii)+1:k(ii+1)-1);
    end
end

