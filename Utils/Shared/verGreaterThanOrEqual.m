function b = verGreaterThanOrEqual(tool, version)

if verLessThan(tool,version)
    b = false;
else
    b = true;
end

