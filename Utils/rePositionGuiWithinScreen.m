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
set(hfig, 'units','normalized', 'position',p);

% Change units back to initial state
set(hfig, 'units', uf0);
