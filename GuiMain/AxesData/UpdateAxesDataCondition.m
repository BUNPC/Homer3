function guiMain = UpdateAxesDataCondition(guiMain, group, currElem)

CondNames = group.CondNames;

CondNamesCurrElem = getCondUtil(currElem.procElem);
for jj=1:length(CondNames)
    k = find(strcmp(['-- ', CondNames{jj}], CondNamesCurrElem));
    if ~isempty(k)
        CondNames{jj} = ['-- ', CondNames{jj}];
    end
end
set(guiMain.handles.popupmenuConditions, 'string', CondNames);
guiMain.condition = getCondition(guiMain);
set(guiMain.handles.popupmenuConditions, 'value', guiMain.condition);




% -------------------------------------------------------------
function CondNames = getCondUtil(procElem)
% Function to determine which conditions at any level are being utilized by 
% having a stim there. It marks the conditions being used by 
% adding a prefix '-- ' to the condition name.  
CondNames = procElem.CondNames;

if strcmp(procElem.type,'run')
    for ii=1:size(procElem.s,2)
        if ismember(abs(1), procElem.s(:,ii))
            CondNames{ii} = ['-- ', CondNames{ii}];
        end
    end
elseif strcmp(procElem.type,'subj')
    for ii=1:length(procElem.runs)
        CondNamesRun = getCondUtil(procElem.runs(ii));
        for jj=1:length(CondNames)
            k = find(strcmp(['-- ', CondNames{jj}], CondNamesRun));
            if ~isempty(k)
                CondNames{jj} = ['-- ', CondNames{jj}];
            end
        end        
    end
elseif strcmp(procElem.type,'group')
    for ii=1:length(procElem.subjs)
        CondNamesSubj = getCondUtil(procElem.subjs(ii));
        for jj=1:length(CondNames)
            k = find(strcmp(['-- ', CondNames{jj}], CondNamesSubj));
            if ~isempty(k)
                CondNames{jj} = ['-- ', CondNames{jj}];
            end
        end        
    end
end


