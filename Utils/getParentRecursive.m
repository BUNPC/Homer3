function top = getParentRecursive(obj)
%   Returns topmost parent of a given graphics object using getParent function.
    while (~isempty(obj))
        top = obj;
        obj = obj.getParent();
    end
end

