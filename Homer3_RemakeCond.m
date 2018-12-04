function Homer3_RemakeCond(stim)
global hmr

if isempty(hmr)
    return;
end

hmr.dataTree.group.CondNames = stim.CondNamesGroup;
hmr.dataTree.currElem        = stim.currElem;
i = hmr.dataTree.currElem.iSubj;
j = hmr.dataTree.currElem.iRun;
hmr.dataTree.group.subjs(i).runs(j).s              = hmr.dataTree.currElem.procElem.s;
hmr.dataTree.group.subjs(i).runs(j).CondNames      = hmr.dataTree.currElem.procElem.CondNames;
hmr.dataTree.group.subjs(i).runs(j).CondName2Group = hmr.dataTree.currElem.procElem.CondName2Group;

hmr.dataTree.group.SetConditions();

hmr.dataTree.DisplayCurrElem(hmr.guiMain);
hmr.guiMain = UpdateAxesDataCondition(hmr.guiMain, hmr.dataTree);

% saveGroup(hmr.group);

