function deleteNamespace(nm)
global namespace
if isdeployed()
    return;
end
if nargin==0
    pname = filesepStandard(pwd);
elseif ~isdeployed()
    pname = filesepStandard((fileparts(which(nm))));
end

k = [];
for ii = 1:length(namespace)
    if strcmp(namespace(ii).name, nm)
        k = [k,ii]; %#ok<AGROW>
    end
end
namespace(k) = [];


