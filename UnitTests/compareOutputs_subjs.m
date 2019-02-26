function compareOutputs_subjs(group_h2, group_h3, type)

prec = -10;
if isempty(group_h2) || isempty(group_h3)
    return;
end
for qq=1:length(group_h3.group.subjs)
    yavg_h2 = eval( sprintf('group_h2.group.subjs(qq).procResult.%s;', type) );
    yavg_h3 = eval( sprintf('group_h3.group.subjs(qq).procStream.output.%s;', type) );
    for ll=1:size(yavg_h3,2)
        for mm=1:size(yavg_h3,3)
            for nn=1:size(yavg_h3,4)
                if ~isequal_prec(yavg_h2(:,ll,mm,nn), yavg_h3(:,ll,mm,nn), prec)
                    fprintf('Subj %d: %s data for Hb type %d, Ch %d, Cond %d does not match\n', qq, type, ll, mm, nn);
                end
            end
        end
    end
end
