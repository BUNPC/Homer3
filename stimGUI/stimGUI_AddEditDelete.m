function stimGUI_AddEditDelete(tPts, iS_lst)
% Usage:
%
%     stimGUI_AddEditDelete(tPts,iS_lst)
%
% Inputs:
%
%     tPts  - time range selected in stim.currElem.procElem.t
%     iS_lst - indices in tPts of existing stims

global hmr

dataTree = hmr.dataTree;

if isempty(tPts)
    return;
end

actionLst = {};

CondNamesGroup = dataTree.group.GetCondNames();
tc             = dataTree.currElem.procElem.GetTime();

% Create menu actions list
for ii=1:nCond
    actionLst{ii} = sprintf('%s', CondNamesGroup{ii});
end
actionLst{end+1} = 'New condition';
if ~isempty(iS_lst)
    actionLst{end+1} = 'Toggle active on/off';
    actionLst{end+1}='Delete';
    menuTitleStr = sprintf('Edit/Delete stim mark(s) at t=%0.1f-%0.1f to...', ...
                           tc(tPts(iS_lst(1))), ...
                           tc(tPts(iS_lst(end))));
else
    menuTitleStr = sprintf('Add stim mark at t=%0.1f...', ...
                           tc(tPts(1)));
end
actionLst{end+1} = 'Cancel';
nActions = length(actionLst);
ch = menu(menuTitleStr,actionLst);

% Get users responce to menu question

% Cancel
if ch==nActions || ch==0
    return;
end


% New stim
if(isempty(iS_lst))
    
    % Add new stim with new group condition
    if ch==nCond+1
        CondNameNew = inputdlg('','New Condition name');
        if isempty(CondNameNew)
            stim = stim0;
            return;
        end
        while ~isempty(find(strcmp(CondNameNew{1}, CondNamesGroup)))
            CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
            if isempty(CondNameNew)
                stim = stim0;
                return;
            end
        end

    % Add new stim to exiting group condition. Condition 
    % might or might not exist in the run. This elseif 
    % takes care of both cases.
    elseif ch<=nCond
        
        % Find the column in s that has the chosen condition 
        flag = 0;

    end

% Existing stim
else

    % Delete stim
    if ch==nActions-1 & nActions==nCond+4

        % Delete stim entry from userdata first 
        % because it depends on stim.currElem.procElem.s
        ;

    % Toggle active/inactive stim
    elseif ch==nActions-2 & nActions==nCond+4

        ;
        
    % Edit stim
    elseif ch<=nCond+1

        % Before moving stim, find it's condition to be able to 
        % to use it to check whether that condition is empty of stims. 
        % Then if the stim's previous condition is empty query user about 
        % whether it should be deleted

        % Save original stim values before reassigning them and then zero them out 
        % from their original columns.
        
        % Assign new condition to edited stim
        if ch==nCond+1
            
            CondNameNew = inputdlg('','New Condition name');
            
        else
            
            % Find the column in s that has the chosen condition
            
        end
        
    end
end

