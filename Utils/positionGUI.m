function positionGUI(hFig, xpos, ypos, xsize, ysize)

% Position and size GUI with handle hFig, relative to screen 

if ~exist('xsize','var')
    xsize = .75;
end
if ~exist('ysize','var')
    ysize = .75;
end

% Screen/monitor handle
hScr = 0;


us0 = get(0, 'units');
uf0 = get(hFig, 'units');

% Set screen units to be same as GUI
set(hScr, 'units','normalized');
set(hFig, 'units','normalized');

% Get positions for screen and GUI
ps = get(hScr, 'MonitorPositions');
pf = get(hFig, 'position');

% To work correctly for mutiple sceens, ps must be sorted in ascending order
ps = sort(ps,'ascend');

% Find which monitor GUI is in
for ii = 1:size(ps,1)
    if (pf(1)+pf(3)/2) < (ps(ii,1)+ps(ii,3))
        break;
    end
end

%set(hFig, 'units','pixels', 'position',[pf(1)-pf(3)/xsize*p(ii,3), pf(2)-pf(3)/ysize*p(ii,4), xsize*p(ii,3), ysize*p(ii,4)]);
d = ps(ii,3) - (pf(1)+ xsize * ps(ii,3));
if d<0
    xoffset = d+.1*d;
else
    xoffset = 0;
end
set(hFig, 'position',[pf(1)+xoffset, pf(2), xsize*ps(ii,3), ysize*ps(ii,4)]);

set(hScr, 'units',us0);
set(hFig, 'units',uf0);

