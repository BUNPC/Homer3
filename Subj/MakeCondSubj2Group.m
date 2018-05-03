function CondSubj2Group = MakeCondSubj2Group(subj, CondNamesGroup)

CondSubj2Group = zeros(1, length(subj.CondNames));
if ~exist('CondNamesGroup','var') | isempty(CondNamesGroup)
    CondSubj2Group = 1:length(subj.CondNames);
    return;
end
for ii=1:length(subj.CondNames)
    CondSubj2Group(ii) = find(strcmp(CondNamesGroup, subj.CondNames{ii}));
end
