function what_changed = stimGUI_AddEditDelete(tPts, iS_lst, auxflag)
% Usage:
%
%     stimGUI_AddEditDelete(tPts,iS_lst,auxflag)
%
% Inputs:
%
%     tPts  - time range selected in stim.currElem.procElem.t
%     iS_lst - indices in tPts of existing stims

global stim
what_changed={};

if isempty(tPts)
    return;
end

if(~exist('auxflag','var'))
    auxflag = 0;
end

stim0 = stim;
actionLst = {};
nCond = length(stim.CondNamesGroup);
CondNameNew = '';

% Create menu actions list
for ii=1:nCond
    actionLst{ii} = sprintf('%s',stim.CondNamesGroup{ii});
end
actionLst{end+1} = 'New condition';
if ~isempty(iS_lst)
    actionLst{end+1} = 'Toggle active on/off';
    actionLst{end+1}='Delete';
    menuTitleStr = sprintf('Edit/Delete stim mark(s) at t=%0.1f-%0.1f to...', ...
                           stim.currElem.procElem.t(tPts(iS_lst(1))), ...
                           stim.currElem.procElem.t(tPts(iS_lst(end))));
else
    menuTitleStr = sprintf('Add stim mark at t=%0.1f...', ...
                           stim.currElem.procElem.t(tPts(1)));
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
        while ~isempty(find(strcmp(CondNameNew{1}, stim.CondNamesGroup)))
            CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
            if isempty(CondNameNew)
                stim = stim0;
                return;
            end
        end
        stim.currElem.procElem.CondNames{end+1} = CondNameNew{1};
        stim.currElem.procElem.s(tPts,end+1) = 1;
        stim.currElem.procElem.CondRun2Group(end+1) = ch;
        stim.CondNamesGroup{ch} = CondNameNew{1};

    % Add new stim to exiting group condition. Condition 
    % might or might not exist in the run. This elseif 
    % takes care of both cases.
    elseif ch<=nCond
        
        % Find the column in s that has the chosen condition 
        flag = 0;
        for iS=1:length(stim.currElem.procElem.CondNames)
            if strcmp(stim.currElem.procElem.CondNames{iS}, stim.CondNamesGroup{ch})
                flag = 1;
                break;
            end
        end
        if flag==0
            iS = length(stim.currElem.procElem.CondNames)+1;
            stim.currElem.procElem.CondNames{iS} = stim.CondNamesGroup{ch};
            stim.currElem.procElem.CondRun2Group(iS) = ch;
        end
        stim.currElem.procElem.s(tPts,iS) = 1;

    end

    % Add new stim entry to userdata
    data = {};
    for ii=1:length(tPts)
        t = stim.currElem.procElem.t(tPts(ii));
        for jj=1:size(stim.userdata.data,1)
            if(stim.userdata.data{jj,1} > t)
                break;
            end
            data(jj,:) = stim.userdata.data(jj,:);
        end
        data(end+1,:) = [{t},repmat({''},1,size(stim.userdata.data,2)-1)];
        stim.userdata.data = [data; stim.userdata.data(jj:end,:)];
    end

% Existing stim
else

    % Delete stim
    if ch==nActions-1 & nActions==nCond+4
        % Delete stim entry from userdata first 
        % because it depends on stim.currElem.procElem.s
        [lstR,lstC] = find(abs(stim.currElem.procElem.s)==1);
        lstR = sort(lstR);
        jj=1;
        for ii=1:length(iS_lst)
            foo = find(lstR == tPts(iS_lst(ii)));
            if ~isempty(foo)
                lst3(jj) = foo;
                jj=jj+1;
            end
        end
        stim.userdata.data(lst3,:) = [];
        
        % Before deleting stim, find it's condition to be able to 
        % to use it to check whether that condition is empty of stims. 
        % Then if the stim's previous condition is empty query user about 
        % whether it should be deleted
        stim.currElem.procElem.s(tPts(iS_lst),:) = 0;        
        
    % Toggle active/inactive stim
    elseif ch==nActions-2 & nActions==nCond+4
        stim.currElem.procElem.s(tPts(iS_lst),:) = stim.currElem.procElem.s(tPts(iS_lst),:) .* -1;

    % Edit stim
    elseif ch<=nCond+1

        % Before moving stim, find it's condition to be able to 
        % to use it to check whether that condition is empty of stims. 
        % Then if the stim's previous condition is empty query user about 
        % whether it should be deleted
        [lstR,lstC] = find(stim.currElem.procElem.s(tPts(iS_lst),:)~=0);

        % Save original stim values before reassigning them and then zero them out 
        % from their original columns.
        for ii=1:length(iS_lst)
            v(ii) = stim.currElem.procElem.s(tPts(iS_lst(lstR(ii))),lstC(ii));
            stim.currElem.procElem.s(tPts(iS_lst(lstR(ii))),lstC(ii)) = 0;
        end
        
        % Assign new condition to edited stim
        if ch==nCond+1
            
            CondNameNew = inputdlg('','New Condition name');
            if isempty(CondNameNew)
                stim = stim0;
                return;
            end
            while ~isempty(find(strcmp(CondNameNew, stim.CondNamesGroup)))
                CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
                if isempty(CondNameNew)
                    stim = stim0;
                    return;
                end
            end            
            stim.currElem.procElem.CondNames{end+1} = CondNameNew{1};
            stim.currElem.procElem.s(tPts(iS_lst(lstR)),end+1) = v;
            stim.currElem.procElem.CondRun2Group(end+1) = ch;       
            stim.CondNamesGroup{ch} = CondNameNew{1};
            
        else
            
            % Find the column in s that has the chosen condition
            flag = 0;
            for iS=1:length(stim.currElem.procElem.CondNames)
                if strcmp(stim.currElem.procElem.CondNames{iS}, stim.CondNamesGroup{ch})
                    flag = 1;
                    break;
                end
            end
            if flag==0
                iS = length(stim.currElem.procElem.CondNames)+1;
                stim.currElem.procElem.CondRun2Group(iS) = ch;
            end
            stim.currElem.procElem.CondNames{iS} = stim.CondNamesGroup{ch};
            stim.currElem.procElem.s(tPts(iS_lst(lstR)),iS) = v;
            
        end
        
    end
end



