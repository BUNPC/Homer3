function deleteNamespace(nm)
global namespace
if isdeployed()
    return;
end
if nargin==0
    return
end
if strcmp(nm, 'all')
    namespace = [];
end
k = [];
for ii = 1:length(namespace)
    if strcmp(namespace(ii).name, nm)
        k = [k,ii]; %#ok<AGROW>
    end
end
namespace(k) = [];


