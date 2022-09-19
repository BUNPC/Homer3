function generateSimData(dirname, format)
if ~exist('dirname','var')
    dirname = pwd;
end
if ~exist('format','var')
    format = '.snirf';
end
dirname = filesepStandard(dirname);

files = DataFilesClass(dirname, format, 'standalone').files;
for ii = 1:length(files)
    if ~isempty(findstr(files(ii).name, '_sim'))
        continue;
    end
    obj = generateSimDataOneFile([files(ii).rootdir, files(ii).name]);
    
    [p,f,e] = fileparts([files(ii).rootdir, files(ii).name]);
    fname = [filesepStandard(p),f,'_sim',e];
    fprintf('Saving simulated data in %s\n', fname);
    obj.Save(fname);
end




% ---------------------------------------------------------------
function obj = generateSimDataOneFile(obj)
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
            if nTpts-iTptE < stepsize
                iTptE = nTpts;
            end
            d(iBlk).dataTimeSeries(iTptS:iTptE, iM) = y;
        end
    end
end
obj.data = d;

