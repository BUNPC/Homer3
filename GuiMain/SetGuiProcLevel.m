function SetGuiProcLevel(handles, iGroup, iSubj, iRun, procLevelSelect)
global hmr

% Function implements rules for which currElem are chosen in responce to
% various combinations of listboxFiles and proc-level radiobuttons
% selections

% Set new GUI proc level state based on current GUI selections of listboxFiles
% (iGroup, iSubj, iRun) and proc level radio buttons (procType)

% There are nine possible current settings from which to decide what the
% new proc level should be 

if all([iGroup, iSubj, iRun])
    listboxFilesMap = hmr.rid;
elseif all([iGroup, iSubj])
    listboxFilesMap = hmr.sid;
else
    listboxFilesMap = hmr.gid;
end

if     listboxFilesMap == hmr.rid && procLevelSelect==hmr.rid   % Case 1: Input  - File entry maps to run(iGroup, iSubj, iRun);  Proc level setting: Run
    set(handles.radiobuttonProcTypeRun, 'value',1);             %         Output - Proc level setting: run;      currElem: run(iGroup, iSubj, iRun)
    hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);              
elseif listboxFilesMap == hmr.sid && procLevelSelect==hmr.rid   % Case 2: Input  - File entry maps to subj(iGroup, iSubj);  Proc level setting: Run
    set(handles.radiobuttonProcTypeSubj, 'value',1);            %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);                    
elseif listboxFilesMap == hmr.gid && procLevelSelect==hmr.rid   % Case 3: Input  - File entry maps to group(iGroup);      Proc level setting: Run
    set(handles.radiobuttonProcTypeGroup, 'value',1);           %         Output - Proc level setting: Group;      currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);                           
elseif listboxFilesMap == hmr.rid && procLevelSelect==hmr.sid   % Case 4: Input  - File entry maps to run(iGroup, iSubj, iRun); Proc level setting: Subj
    set(handles.radiobuttonProcTypeSubj, 'value',1);            %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);             
elseif listboxFilesMap == hmr.sid && procLevelSelect==hmr.sid   % Case 5: Input  - File entry maps to subj(iGroup, iSubj);   Proc level setting: Subj
    set(handles.radiobuttonProcTypeSubj, 'value',1);            %         Output - Proc level setting: Subj;     currElem: subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);                    
elseif listboxFilesMap == hmr.gid && procLevelSelect==hmr.sid   % Case 6: Input  - File entry maps to group(iGroup);  Proc level setting: Subj
    set(handles.radiobuttonProcTypeGroup, 'value',1);           %         Output - Proc level setting: Group;    currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);                           
elseif listboxFilesMap == hmr.rid && procLevelSelect==hmr.gid   % Case 7: Input  - File entry maps to run(iGroup, iSubj, iRun);   Proc level setting: Group
    set(handles.radiobuttonProcTypeGroup, 'value',1);           %         Output - Proc level setting: Group;    currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);                           
elseif listboxFilesMap == hmr.sid && procLevelSelect==hmr.gid   % Case 8: Input  - File entry maps to subj(iGroup, iSubj);    Proc level setting: Group
    set(handles.radiobuttonProcTypeSubj, 'value',1);            %         Output - Proc level setting: Subj;     subj(iGroup, iSubj)
    hmr.dataTree.SetCurrElem(iGroup, iSubj);                    
elseif listboxFilesMap == hmr.gid && procLevelSelect==hmr.gid   % Case 9: Input  - File entry maps to group(iGroup);   Proc level setting: Group
    set(handles.radiobuttonProcTypeGroup, 'value',1);           %         Output - Proc level setting: Group;    currElem: group(iGroup)
    hmr.dataTree.SetCurrElem(iGroup);                           
end

