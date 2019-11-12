function pretty_print_struct(st, indent, option)

spaces = '';

if nargin==0
    return
end
if nargin>1
    if iswholenum(indent)
        spaces = blanks(indent);
    elseif ischar(indent)
        spaces = blanks(length(indent));
    end
end
if nargin<2
    option = 1;
end

if isempty(st)
    return;
end

if isstruct(st) || isobject(st)
    s = evalc('disp(st)');
    c = str2cell(s,10);
    for ii=1:length(c)
        if option==1
            fprintf('%s%s\n', spaces, strtrim_improve(c{ii}));
        elseif option==2
            fprintf('%s%s\n', spaces, c{ii});
        end
    end
else
    str = '';
    for jj=1:ndims(st)
        if jj==1
            str = num2str(size(st,jj));
        else
            str = sprintf('%sx%s', str, num2str(size(st,jj)));
        end
    end    
    fprintf('        %s: [%s %s]\n', inputname(1), str, class(st));
end