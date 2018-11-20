function positionGUI(hFig, xpos, ypos, xsize, ysize)

% Position and size GUI with handle hFig, relative to screen 

if ~exist('xpos','var')
    xpos  = .28;
end
if ~exist('ypos','var')
    ypos  = .10;
end
if ~exist('xsize','var')
    xsize = .72;
end
if ~exist('ysize','var')
    ysize = .82;
end

units = get(hFig, 'units');
p = get(0, 'ScreenSize');
set(hFig, 'units','pixels', 'position',[xpos*p(3), ypos*p(4), xsize*p(3), ysize*p(4)]);
set(hFig, 'units',units);
set(hFig, 'visible','on');

