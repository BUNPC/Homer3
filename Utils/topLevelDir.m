function d = topLevelDir()

if ispc()
    d = 'c:';
else
    d = '/';
end

