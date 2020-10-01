function PlotData(t, y, hbType, channels)

% Plot always to 
hf = 5; 
try
    close(hf);
catch
end

% y = y*1e6;

figure(hf);
axes;
p = get(gcf, 'position');
set(gcf, 'position', [p(1), p(2), p(3)*1.3, p(4)]);
hold on;
for iHb = 1:length(hbType)
    for iCh = 1:length(channels)
        plot(t, y(:, hbType(iHb), channels(iCh)));
    end
end
xlim([min(t), max(t)]);
hold off;

