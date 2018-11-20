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
hmr.group.subjs(i).runs(j).CondName2Group = hmr.currElem.procElem.CondName2Group;

hmr.group.SetConditions();

DisplayCurrElem(hmr.currElem, hmr.guiMain)

hmr.guiMain = UpdateAxesDataCondition(hmr.guiMain, hmr.group, hmr.currElem);

% saveGroup(hmr.group);

