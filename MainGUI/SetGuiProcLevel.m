function SetGuiProcLevel(handles, iGroup, iSubj, iSess, iRun, procLevelSelect)
global maingui

% Function implements rules for which currElem are chosen in responce to
% various combinations of listboxGroupTree and proc-level radiobuttons
% selections

% Set new GUI proc level state based on current GUI selections of listboxGroupTree
% (iGroup, iSubj, iRun) and proc level radio buttons (procType)

% There are nine possible current settings from which to decide what the
% new proc level should be 

if all([iGroup, iSubj, iSess, iRun])
    listboxGroupTreeMap = maingui.rid;
elseif all([iGroup, iSubj, iSess])
    listboxGroupTreeMap = maingui.eid;
elseif all([iGroup, iSubj])
    listboxGroupTreeMap = maingui.sid;
else
    listboxGroupTreeMap = maingui.gid;
end
views = maingui.listboxGroupTreeParams.views;
viewSetting = maingui.listboxGroupTreeParams.viewSetting;

% Save changes to any child GUIs before switching context
SaveChildGuis();

% First handle the cases NOT dependent on view type
if     listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.rid   % Case 1: Input  - List Entry maps to run(iGroup, iSubj, iRun);  Proc level setting: Run
    set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: run;      currElem: run(iGroup, iSubj, iRun)
    maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess, iRun);
elseif listboxGroupTreeMap == maingui.eid && procLevelSelect==maingui.rid   % Case 2: Input  - List Entry maps to subj(iGroup, iSubj);  Proc level setting: Run
    set(handles.radiobuttonProcTypeSess, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
elseif listboxGroupTreeMap == maingui.sid && procLevelSelect==maingui.rid   % Case 2: Input  - List Entry maps to subj(iGroup, iSubj);  Proc level setting: Run
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == maingui.gid && procLevelSelect==maingui.rid   % Case 3: Input  - List Entry maps to group(iGroup);      Proc level setting: Run
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;      currElem: group(iGroup)
    maingui.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == maingui.eid && procLevelSelect==maingui.eid   % Case 5: Input  - List Entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSess, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
elseif listboxGroupTreeMap == maingui.sid && procLevelSelect==maingui.eid   % Case 5: Input  - List Entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == maingui.gid && procLevelSelect==maingui.eid   % Case 6: Input  - List Entry maps to group(iGroup);  Proc level setting: Subj
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
    maingui.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == maingui.eid && procLevelSelect==maingui.sid   % Case 5: Input  - List Entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSess, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
elseif listboxGroupTreeMap == maingui.sid && procLevelSelect==maingui.sid   % Case 5: Input  - List Entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == maingui.gid && procLevelSelect==maingui.sid   % Case 6: Input  - List Entry maps to group(iGroup);  Proc level setting: Subj
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
    maingui.dataTree.SetCurrElem(iGroup);elseif listboxGroupTreeMap == maingui.gid && procLevelSelect==maingui.gid   % Case 9: Input  - List Entry maps to group(iGroup);   Proc level setting: Group
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
    maingui.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == maingui.sid && procLevelSelect==maingui.gid   % Case 8: Input  - List Entry maps to subj(iGroup, iSubj);    Proc level setting: Group
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == maingui.eid && procLevelSelect==maingui.gid   % Case 8: Input  - List Entry maps to subj(iGroup, iSubj);    Proc level setting: Group
    set(handles.radiobuttonProcTypeSess, 'value',1);                %         Output - Proc level setting: Subj;     subj(iGroup, iSubj)
    maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
else
    % Now handle the special cases (all at the run-level) which are view type dependent
    if viewSetting == views.RUNS
        if listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.eid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeSess, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
            maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.sid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
            maingui.dataTree.SetCurrElem(iGroup, iSubj);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup);
        end
    elseif viewSetting == views.NOSESS
        if listboxGroupTreeMap == maingui.rid                                 % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess, iRun);
        end
    elseif viewSetting == views.SESS
        if listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.eid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeSess, 'value',1);                 %         Output - Proc level setting: Run;     currElem: subj(iGroup, iSubj)
            maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.sid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeSubj, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup, iSubj);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeGroup, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup);
        end
    elseif viewSetting == views.SUBJS
        if listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.eid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeSess, 'value',1);                 %         Output - Proc level setting: Run;     currElem: subj(iGroup, iSubj)
            maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.sid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeSubj, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup, iSubj);
        elseif listboxGroupTreeMap == maingui.rid && procLevelSelect==maingui.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeGroup, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            maingui.dataTree.SetCurrElem(iGroup);
        end
    elseif viewSetting == views.GROUP
        if listboxGroupTreeMap == maingui.rid
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;     currElem: subj(iGroup, iSubj)
            maingui.dataTree.SetCurrElem(iGroup, iSubj, iSess, iRun);
        end
    end
end



% --------------------------------------------------------------------
function SaveChildGuis()
global maingui
if isempty(maingui.childguis)
    return;
end
for ii=1:length(maingui.childguis)
    maingui.childguis(ii).Save();
end



