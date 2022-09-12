function obj = generateSimData(obj)
d = [];
if ischar(obj)
    obj = SnirfClass(obj);
    d = obj.data;
elseif isa(obj, 'SnirfClass')
    d = obj.data;
elseif isa(obj, 'DataClass')
    d = obj;
    obj = SnirfClass(d);
end
ml = d.GetMeasurementList('matrix');
for iBlk = length(d)
    nTpts = size(d(iBlk).dataTimeSeries,1);
    for iM = 1:length(d(iBlk).measurementList)
        data = ml(iM,:);
        stepsize = floor(nTpts / length(data));
        for iDt = 1:length(data)
            y = data(iDt);
            iTptS = (iDt-1) * stepsize + 1;
            iTptE = iTptS + stepsize - 1;            
            if iTptE > nTpts
                iTptE = nTpts;
            end
            d(iBlk).dataTimeSeries(iTptS:iTptE, iM) = y;
        end
    end
end

obj.data = d;

