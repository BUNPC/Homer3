function [verstr, V] = version2string(V)

verstr = '';
if ~exist('V','var') || isempty(V)
    V = getVernum();
end
if ischar(V)
    verstr = V;
    return
end

% Error checking
for ii = length(V):-1:1
    if ~ischar(V{ii})
        return;
    end
    if ~isnumber(V{ii}) && ii<4
        return;
    end
    if ii<4
        break;
    end
end

% Generate vresion string from version cell array
for kk = length(V):-1:1
    if kk>3
        continue;
    end
    if (kk+1)>length(V) || isnumber(V{kk+1})
        verstr = sprintf('%s.%s', V{kk}, verstr);
    else
        verstr = sprintf('%s, %s', V{kk}, verstr);
    end
end
if isempty(verstr)
    return
end
if verstr(end) == '.'
    verstr(end) = '';
end

