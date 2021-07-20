function c = getNamespace()
global namespace

% fprintf('In getNamespace:\n');

if length(namespace)==1
    c = namespace(1).name;
    return;
end

c = '';
s = dbstack();
if isempty(s)
    return;
end


for jj = length(s):-1:1
%     fprintf('  s(%d).file = %s:\n', jj, s(jj).file);
%     fprintf('  s(%d).name = %s:\n', jj, s(jj).name);

    try
        pname = filesepStandard(which(s(jj).file));
    catch
        continue
    end
    for ii = 1:length(namespace)
%         fprintf('  namespace = [%s, %s]\n', namespace(ii).name, namespace(ii).pname);
        if isRootpathsSame(pname, namespace(ii).pname)
            c = namespace(ii).name;
            return;
        end
    end
%     fprintf('\n');
end



% ---------------------------------------------------------
function b = isRootpathsSame(p1, p2)
b = false;
p1 = filesepStandard(p1);
p2 = filesepStandard(p2);
k = findstr(p1, p2);
if isempty(k)
    return;
end
b = true;


