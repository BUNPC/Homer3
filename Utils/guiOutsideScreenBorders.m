function [p, b] = guiOutsideScreenBorders(hObject)
%
% Syntax:
%    [p, b] = guiOutsideScreenBorders(hObject)
%
% Description:
%    Calculates the amount that a figure with handle hObject falls outside of screen borders and returns 
%    the new position, p, which shifts the original position by the amount to have the entire figure 
%    within screen borders. All calculations are made in character units. If the original position is 
%    already entirely within screen borders then p is set to the original position. A set of booleans 
%    b is also returned. b is true if the correspoinding dimension is outside the screen border.
%

b = [0, 0, 0, 0];
u0 = get(hObject, 'units');

set(hObject, 'units','characters');
p = get(hObject,'position');

% Set screen units to be same as GUI
set(0,'units','characters');
Ps = get(0,'MonitorPositions');

% Find which monitor GUI is in
for ii=1:length(Ps(:,1))
    if (p(1)+p(3)/2) < (Ps(ii,1)+Ps(ii,3))
        break;
    end
end

% Get screen borders 
buffer_x = Ps(ii,3)*.02;
buffer_y = Ps(ii,4)*.05;
ScreenWidth     = Ps(ii,3);
ScreenHeight    = Ps(ii,4);
ScreenSideLeft  = Ps(ii,1)+buffer_x;
ScreenSideRight = Ps(ii,1)+ScreenWidth-buffer_x;
ScreenFloor     = Ps(ii,2)+buffer_y;
ScreenCeiling   = Ps(ii,2)+ScreenHeight-buffer_y;

% Compare GUI position size against screen borders 
if p(1)+p(3)>=ScreenSideRight || p(1)<ScreenSideLeft
    if p(1)+p(3)>=ScreenSideRight
        b(1) = (p(1)+p(3)) - ScreenSideRight;
    else
        b(1) = p(1) - ScreenSideLeft;
    end
end
if p(2)+p(4)>=ScreenCeiling || p(2)<ScreenFloor
    if p(2)+p(4)>=ScreenCeiling
        b(2) = (p(2)+p(4)) - ScreenCeiling;
    else
        b(2) = p(2) - ScreenFloor;
    end
end
if p(3)>=ScreenWidth
    b(3) = p(3) - ScreenWidth;
end

if p(4)>=ScreenHeight
    b(4) = p(4) - ScreenHeight;
end
p = p - b;

% Set the screen units back to pixels
set(0,'units','pixels');
set(hObject, 'units',u0);
