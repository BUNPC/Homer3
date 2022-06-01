function [nirs2, orderNew] = shuffleChannels(nirs1_0, filename, orderNew)

if ischar(nirs1_0)
    nirs1 = NirsClass(nirs1_0);
else
    nirs1 = nirs1_0;
end
if ~exist('filename','var') || isempty(filename)
    filename = nirs1.GetFilename();
end
if ~exist('orderNew','var')
    orderNew = [];
end

nwl = length(nirs1.SD.Lambda);
N = size(nirs1.SD.MeasList,1)/nwl;
if isempty(orderNew)
    orderNew = randperm(N);
end
nirs2 = NirsClass(nirs1);
for iW = 1:nwl
    iS = (iW-1)*N + 1;
    iE = (iW-1)*N + N;
    nirs2.SD.MeasList(iS:iE,:) = nirs1.SD.MeasList(iS-1 + orderNew, :);
    nirs2.d(:,iS:iE)           = nirs1.d(:,iS-1 + orderNew);
end

if ischar(nirs1_0)
    nirs2.Save(filename, 'overwrite');
end

