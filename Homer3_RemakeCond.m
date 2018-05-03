function Homer3_RemakeCond(stim)
global hmr

if isempty(hmr)
    return;
end

hmr.group.CondNames = stim.CondNamesGroup;
hmr.currElem        = stim.currElem;
i = hmr.currElem.iSubj;
j = hmr.currElem.iRun;
hmr.group.subjs(i).runs(j).s             = hmr.currElem.procElem.s;
hmr.group.subjs(i).runs(j).CondNames     = hmr.currElem.procElem.CondNames;
hmr.group.subjs(i).runs(j).CondRun2Group = hmr.currElem.procElem.CondRun2Group;

hmr.group = MakeCondNamesGroup(hmr.group);

DisplayCurrElem(hmr.currElem, hmr.axesData);

hmr.axesData = UpdateAxesDataCondition(hmr.axesData, hmr.group, hmr.currElem);

% saveGroup(hmr.group);

