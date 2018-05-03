function saveSubj(subj)
global hmr
group = hmr.group;


iSubj = subj.iSubj;

group.subjs(iSubj).procInput  = subj.procInput; 
group.subjs(iSubj).procResult = subj.procResult;

save('groupResults.mat','-mat','group');

hmr.group = group;
