function [verstr, V] = version2string()

verstr = '';

V = getVernum();
if length(V)<2
    return;
end

if str2num(V{2})==0 || isempty(V{2})
    verstr = sprintf('v%s', [V{1}]);
else
    verstr = sprintf('v%s', [V{1} '.' V{2}]);
end

if length(V)>2 && ~isempty(V{3})
    if isnumber(V{3})
        if V{3}=='0'
            verstr = sprintf('%s', verstr);
        else
            verstr = sprintf('%s.%s', verstr, V{3});
        end
    else
        verstr = sprintf('%s, %s', verstr, V{3});
    end
end    