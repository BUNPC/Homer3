function saveGroup(group, mode)
global hmr

if ~exist('mode','var')
    mode = 'noruns';
end

hmr.group(1).procResult = group(1).procResult;

% Update group
group = hmr.group;

save('groupResults.mat','-mat','group');

if strcmp(mode, 'saveruns')
    for ii=1:length(group.subjs)
        for jj=1:length(group.subjs(ii).runs)
            SaveRun(group.subjs(ii).runs(jj), 'saveuseredits')
        end
    end
end

