function CondRun2Group = MakeCondRun2Group(run, CondNamesGroup)

CondRun2Group = zeros(1, length(run.CondNames));
if ~exist('CondNamesGroup','var') | isempty(CondNamesGroup)
    CondRun2Group = 1:length(run.CondNames);
    return;
end
for ii=1:length(run.CondNames)
    CondRun2Group(ii) = find(strcmp(CondNamesGroup, run.CondNames{ii}));
end
