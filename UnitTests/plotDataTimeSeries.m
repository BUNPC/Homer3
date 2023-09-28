function k = plotDataTimeSeries(y, iS, iD, iDt, option)
if ~exist('option','var')
    option = '';
end
ml = y.GetMeasurementList('matrix');
k = find(ml(:,1)==iS & ml(:,2)==iD & ml(:,4)==iDt);
if ishandle(1)
    if ~strcmp(option,'keep') && ~strcmp(option,'keepopen') && ~strcmp(option,'open')
        close(1);
    end
end
figure
plot(y.dataTimeSeries(:,k))

