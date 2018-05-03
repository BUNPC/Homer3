function group = MakeCondNamesGroup(group)

%%%% Find condition names for all subjects
for jj=1:length(group.subjs)
    % Always reconstruct subj conditions even
    [group.subjs(jj).CondNames, group.subjs(jj).CondSubj2Run] = ...
        MakeCondNamesSubj(group.subjs(jj).runs);
end
CondNamesSubjTbl = makeCondNamesSubjTbl(group.subjs);
nFiles = size(CondNamesSubjTbl,1);

%%%% Find condition names for whole group
CondNames = group.CondNames;
for iF=1:nFiles
    for iC=1:length(CondNamesSubjTbl{iF})
        if isempty(find(strcmp(CondNames, CondNamesSubjTbl{iF}{iC})))
            CondNames{end+1} = CondNamesSubjTbl{iF}{iC};
        end
    end
end

%%%% Generate mapping of group conditions to subject conditions 
%%%% used when averaging subject HRF to get group HRF
CondGroup2Subj = zeros(nFiles,length(CondNames));
for iC=1:length(CondNames)
    for iF=1:nFiles
        k = find(strcmp(CondNames{iC},CondNamesSubjTbl{iF}));
        if isempty(k)
            CondGroup2Subj(iF,iC) = 0;
        else
            CondGroup2Subj(iF,iC) = k(1);
        end
    end
end

%%%% Generate mappings of subj and run conditions to group conditions.
%%%% These tables are used index subj and run conditions when displaying subj and run HRFs. 
%%%% Also they are used to display conditions with the correct color global
%%%% (ie group) condition color
for jj=1:length(group.subjs)
    group.subjs(jj).CondSubj2Group = ...
              MakeCondSubj2Group(group.subjs(jj), CondNames);
    for kk=1:length(group.subjs(jj).runs)
        group.subjs(jj).runs(kk).CondRun2Group = ...
                   MakeCondRun2Group(group.subjs(jj).runs(kk), CondNames);
    end
end

group.CondNames = CondNames;
group.CondGroup2Subj = CondGroup2Subj;
group.CondColTbl = MakeCondColTbl(group.CondNames);




% ------------------------------------------------------------------
function CondNamesSubjTbl = makeCondNamesSubjTbl(runs, CondNamesSubjTbl)

nSubjs = length(runs);
if ~exist('CondNamesSubjTbl','var')

    CondNamesSubjTbl = cell(nSubjs,1);
    for iR=1:nSubjs
        CondNamesSubjTbl{iR} = runs(iR).CondNames;
    end

else

    for iR=1:nSubjs
        for iTbl=1:length(CondNamesSubjTbl)
            if ~isempty(CondNamesSubjTbl{iTbl}) && strcmp(CondNamesSubjTbl{iTbl}{1}, runs(iR).name)
                 CondNamesSubjTbl{iTbl} = runs(iR).CondNames;
            end
        end
    end

end

