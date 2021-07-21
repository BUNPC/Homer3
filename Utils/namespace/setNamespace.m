function setNamespace(nm)
global namespace
N = 2;

% fprintf('In setNamespace:\n');

if nargin==0
    pname = filesepStandard(pwd);
elseif ~isdeployed()
    pname = filesepStandard((fileparts(which(nm))));
end

if isdeployed()
    namespace(1).name = nm;
    return;
end

if ~isstruct(namespace)
    namespace = [];
end
if length(namespace) >= N
    namespace = [];
end
for ii = 1:length(namespace)
    if strcmp(namespace(ii).name, nm)
        return
    end
end

idx = mod(length(namespace), N+1)+1;
namespace(idx).name = nm;
namespace(idx).pname = pname;

% fprintf('  namespace = [%s, %s]\n', namespace(idx).name, namespace(idx).pname);

