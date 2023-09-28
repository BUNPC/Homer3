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

N = size(nirs1.SD.MeasList,1);
if isempty(orderNew)
    orderNew = randperm(N);
end
nirs2 = NirsClass(nirs1);
nirs2.SD.MeasList = nirs1.SD.MeasList(orderNew,:);
nirs2.d = nirs1.d(:,orderNew);

if ischar(nirs1_0)
    nirs2.Save(filename, 'overwrite');
end

