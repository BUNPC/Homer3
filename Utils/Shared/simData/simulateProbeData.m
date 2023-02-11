function snirf = simulateProbeData(probefile, ntpts)
snirf = SnirfClass.empty();
if ~exist('probefile','var')
    return;
end
if ~exist('ntpts','var')
    ntpts = 1e3;
end

if ~ispathvalid(probefile)
    return;
end

nirs = NirsClass(probefile);
for iM = 1:length(nirs.SD.MeasList)
    [nirs.t, nirs.d(:,iM)] = simulateDataTimeSeries(ntpts);
end
snirf = SnirfClass(nirs.d, nirs.t, nirs.SD, [], []);
[p,f] = fileparts(probefile);
snirf.Save(['./',f,'.snirf']);


