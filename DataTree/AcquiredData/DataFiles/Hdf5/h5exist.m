function b = h5exist(info0, varname)

% 
% b = h5exist(h5info('S_struct_file.h5'), '/S_struct')
%
% b = h5exist(h5info('S_struct_file.h5'), '/S_struct/field_1')
%

b = false;

if ~isstruct(info0) && ~isfield(info0, 'Group') && ~isfield(info0, 'GroupHierarchy')
    info = h5info(info0);
else
    info = info0;
end

if strcmp(varname, info.Name)
    b = true;
    return;
end

for ii=1:length(info.Datasets)
    varname_info = [info.Name, '/', info.Datasets(ii).Name];
    if strcmp(varname, varname_info)
        b = true;
        return;
    end
end

for ii=1:length(info.Groups)
    b = h5exist(info.Groups(ii), varname);
    if b==true
        return;
    end
end

