function orderNew = ScrambleChannelsForGroup(groupPath)
if ~exist('groupPath','var') || isempty(groupPath)
    groupPath = filesepStandard(pwd);
end
d = DataFilesClass(groupPath, '.nirs');
orderNew = [];
for ii = 1:length(d.files)
    filename = [filesepStandard(groupPath), d.files(ii).name];
    if d.files(ii).IsFile()
        [~, ~, ext] = fileparts(filename);
        if strcmp(ext, '.nirs')
            [~, orderNew] = shuffleChannels(filename, [], orderNew);
        end
    end
end

