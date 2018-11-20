function C = str2cell(str, delimiters)

str = deblank(str);

if ~exist('delimiters','var')
    delimiters{1} = sprintf('\n');
elseif ~iscell(delimiters)
    foo{1} = delimiters;
    delimiters = foo;
end

% Get indices of all the delimiters
k=[];
for kk=1:length(delimiters)
    k = [k, find(str==delimiters{kk})];
end
j = find(~ismember([1:length(str)],k));

% 
C = {};
ii=1; kk=1;
while ii<=length(j)
    C{kk} = str(j(ii));
    ii=ii+1;
    while (ii<=length(j)) && ((j(ii)-j(ii-1))==1)
        C{kk}(end+1) = str(j(ii));
        ii=ii+1;
    end
    kk=kk+1;
end

