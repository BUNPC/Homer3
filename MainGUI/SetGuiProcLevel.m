function SetGuiProcLevel(handles, iGroup, iSubj, iRun, procLevelSelect)
global hmr

% Function implements rules for which currElem are chosen in responce to
% various combinations of listboxGroupTree and proc-level radiobuttons
% selections

% Set new GUI proc level state based on current GUI selections of listboxGroupTree
% (iGroup, iSubj, iRun) and proc level radio buttons (procType)

% There are nine possible current settings from which to decide what the
% new proc level should be 

if all([iGroup, iSubj, iRun])
    listboxGroupTreeMap = hmr.rid;
elseif all([iGroup, iSubj])
    listboxGroupTreeMap = hmr.sid;
else
    listboxGroupTreeMap = hmr.gid;
end
views = hmr.listboxGroupTreeParams.views;
viewSetting = hmr.listboxGroupTreeParams.viewSetting;

% First handle the cases NOT dependent on view type
if     listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.rid   % Case 1: Input  - List Entry maps to run(iGroup, iSubj, iRun);  Proc level setting: Run
    set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: run;      currElem: run(iGroup, iSubj, iRun)
    hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
elseif listboxGroupTreeMap == hmr.sid && procLevelSelect==hmr.rid   % Case 2: Input  - List Entry maps to subj(iGroup, iSubj);  Proc level setting: Run
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == hmr.gid && procLevelSelect==hmr.rid   % Case 3: Input  - List Entry maps to group(iGroup);      Proc level setting: Run
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;      currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == hmr.sid && procLevelSelect==hmr.sid   % Case 5: Input  - List Entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);
elseif listboxGroupTreeMap == hmr.gid && procLevelSelect==hmr.sid   % Case 6: Input  - List Entry maps to group(iGroup);  Proc level setting: Subj
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == hmr.gid && procLevelSelect==hmr.gid   % Case 9: Input  - List Entry maps to group(iGroup);   Proc level setting: Group
    set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);
elseif listboxGroupTreeMap == hmr.sid && procLevelSelect==hmr.gid   % Case 8: Input  - List Entry maps to subj(iGroup, iSubj);    Proc level setting: Group
    set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);
else
    % Now handle the special cases (all at the run-level) which are view type dependent
    if viewSetting == views.RUNS
        if listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.sid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeSubj, 'value',1);                %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
            hmr.dataTree.SetCurrElem(iGroup, iSubj);
        elseif listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeGroup, 'value',1);               %         Output - Proc level setting: Group;    currElem: group(iGroup)
            hmr.dataTree.SetCurrElem(iGroup);
        end
    elseif viewSetting == views.SUBJS
        if listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.sid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;     currElem: subj(iGroup, iSubj)
            hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
        elseif listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
        end
    elseif viewSetting == views.ALL
        if listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.sid       % Case 4: Input  - List Entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;     currElem: subj(iGroup, iSubj)
            hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
        elseif listboxGroupTreeMap == hmr.rid && procLevelSelect==hmr.gid   % Case 7: Input  - List Entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
            set(handles.radiobuttonProcTypeRun, 'value',1);                 %         Output - Proc level setting: Run;    currElem: group(iGroup)
            hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
        end
    end
end
