function [fx, fy] = guiUnitConversion(units1, units2)
% 
% Syntax:
%   [fx, fy] = guiUnitConversion()
%   [fx, fy] = guiUnitConversion(units1)
%   [fx, fy] = guiUnitConversion(units1, units2)
%
%
% Description:
%   Function to find unit ratios between any 2 units in the current screen in
%   the x and y directions
%
%
% Examples:
%   [fx, fy] = guiUnitConversion('inches','centimeters')
%   fx = 2.5400
%   fy = 2.5400
% 
%   [fx, fy] = guiUnitConversion('centimeters','inches')
%   fx = 0.3937
%   fy = 0.3937
% 
%   [fx, fy] = guiUnitConversion('centimeters','pixels')
%   fx = 37.7953
%   fy = 37.7953
% 
%   [fx, fy] = guiUnitConversion('pixels','characters')
%   fx = 0.2000
%   fy = 0.0769
%
%
if nargin==0
    units1 = 'characters';
    units2 = 'pixels';
elseif nargin==0
    units2 = 'pixels';
end

hf = figure('visible','off');
hBttn = uicontrol('parent',hf, 'Style','pushbutton', 'Units',units1, 'position',[1,1,1,1], 'visible','off');
set(hBttn, 'units',units2);
p = get(hBttn, 'position');
delete(hBttn);

fx = p(3);
fy = p(4);
