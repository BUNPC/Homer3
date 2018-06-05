function b = isproperty(obj, propname)

if isstruct(obj)
    b = isfield(obj, propname);
else
    b = isprop(obj, propname);    
end
