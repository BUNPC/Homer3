function yrange = GetAxesYRangeForStimPlot(hAxes)

if ~exist('hAxes','var') || isempty(hAxes)
    hAxes = gca;
end

ylim = get(hAxes, 'ylim');

% Fill up the ylim range with the stim by adding and
% subtracting a tiny amount so that the ylim isn't
% automatically changed
d = (1e-4)*(ylim(2)-ylim(1));
% d = 0;
yrange = [ylim(1)+d, ylim(2)-d];

