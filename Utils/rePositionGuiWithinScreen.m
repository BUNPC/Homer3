function rePositionGuiWithinScreen(hfig)

if ~ishandle(hfig)
    return;
end

% Get position correction value 
p = guiOutsideScreenBorders(hfig);

% Apply position correcttion. NOTE: guiOutsideScreenBorders return p 
% in chracter units, therefore temporaily change units to char to apply 
% then pos correction, then change back to initial units before 
% returning from function
u0 = get(hfig, 'units');
set(hfig, 'units', 'characters');

% Apply correction 
set(hfig, 'position', [p(1), p(2), p(3), p(4)]);

% Change units back to initial state
set(hfig, 'units', u0);
