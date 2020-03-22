function pnames = convertToStandardPath(pnames)
if nargin==0    
    return
end
if isempty(pnames)
    return
end
if ~ischar(pnames) && ~iscell(pnames)
    return
end

if ischar(pnames)
    if exist(pnames, 'file')
        pnames = fullpath(pnames);
    end
    pnames(pnames=='\') = '/';
    if pnames(end) ~= '/'
        pnames(end+1) = '/';
    end
    k = strfind(pnames,'///');
    pnames(k) = '';
    k = strfind(pnames,'//');
    pnames(k) = '';
    return
end

for ii=1:length(pnames)
    pnames{ii} = convertToStandardPath(pnames{ii});
end