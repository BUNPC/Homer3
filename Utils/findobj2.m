function hObj = findobj2(h, propname, propvalue, options)

% Find graphic object handle given the parent (or grandparent, etc) handle
% and property name/value pair 

if ~exist('options','var')
    options = '';
end

hObj = [];
hc = get(h, 'children');
for ii = 1:length(hc)
    try 
        if eval( sprintf('strcmp(get(hc(ii), ''%s''), ''%s'')', propname, propvalue) )
            hObj = hc(ii);
            return;
        elseif ~optionExist(options, 'flat')
            hObj = findobj2(hc(ii), propname, propvalue);
            if ~isempty(hObj)
                return;
            end
        end
    catch
        continue
    end
end

