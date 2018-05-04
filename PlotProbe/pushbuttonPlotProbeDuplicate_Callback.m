function pushbuttonPlotProbeDuplicate_Callback(hObject, eventdata, handles)
global hmr

plotprobe = hmr.plotprobe;

hFig   = plotprobe.objs.Figure.h;
tMarkAmp = plotprobe.tMarkAmp;

%%%% Get the zoom level of the original plotProbe axes
figure(hFig);
a = get(gca,'xlim');
b = get(gca,'ylim');


%%%% Create new figure and use same zoom level and axes position 
%%%% as original 
hFig2 = figure();
xlim(a);
ylim(b);
pos = getNewFigPos(hFig);
set(hFig2,'position',pos);
plotprobe.objs.Figure.h = hFig2;

plotprobe = plotProbeAndSetProperties(plotprobe);

%{
if tMarkAmp
    uicontrol('parent',hFig2,'style','text',...
              'units','normalized','position',[.05 .01 .2 .1],...
              'string',sprintf('Amplitude: %0.5g',tMarkAmp),...
              'backgroundcolor',[1 1 1]);
end  
%}      
      
      
      
% ---------------------------------------------
function pos = getNewFigPos(hFig);

p = get(hFig,'position');

% Find upper right corner of figure
pu = [p(1)+p(3), p(2)+p(4)];

% find center position of figure
c = [p(1)+(pu(1)-p(1))/2, p(2)+(pu(2)-p(2))/2];

% determine which direction to move new figure relative 
% to hFig based on which quadrant of the screen the center
% of hFig appears.
scrsz = get(0,'screensize');
if c(1)>scrsz(3)/2
    q=-1;
else
    q=+1;
end
if c(2)>scrsz(4)/2
    r=-1;
else
    r=+1;
end
offsetX = q*scrsz(3)*.1;
offsetY = r*scrsz(4)*.1;

pos = [p(1)+offsetX p(2)+offsetY p(3) p(4)];

