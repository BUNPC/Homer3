function rePositionGuiWithinScreen(hfig)

if ~ishandle(hfig)
    return;
end

% Get position correction value 
p = guiOutsideScreenBorders(hfig);

% Apply position correcttion. NOTE: guiOutsideScreenBorders return p 
% in normalized units, therefore temporaily change units to normalized to apply 
% then pos correction, then change back to initial units before 
% returning from function
uf0 = get(hfig, 'units');
set(hfig, 'units','normalized');
p0 = get(hfig, 'position');
if p(2)<0
    if p(4)-p(2) >= 1
        p(2) = p0(2);
    end
end
set(hfig, 'position',p);

% Change units back to initial state
set(hfig, 'units', uf0);
