function group = ResetGroup(group)

group.procResult = InitProcResultGroup();
group.SD = [];
for jj=1:length(group.subjs)
    group.subjs(jj) = ResetSubj(group.subjs(jj));
end

