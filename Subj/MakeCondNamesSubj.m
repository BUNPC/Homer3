function [CondNames CondSubj2Run] = MakeCondNamesSubj(runs)

CondNamesRunTbl = makeCondNamesRunTbl(runs);

CondNames={};
nFiles = size(CondNamesRunTbl,1);
for iF=1:nFiles
    for iC=1:length(CondNamesRunTbl{iF})
        CondNames{end+1} = CondNamesRunTbl{iF}{iC};
    end
end
CondNames = unique(CondNames);

% Generate the second output parameter - CondSubj2Run using the 1st
CondSubj2Run = zeros(nFiles,length(CondNames));
for iC=1:length(CondNames)
    for iF=1:nFiles
        k = find(strcmp(CondNames{iC},CondNamesRunTbl{iF}));
        if isempty(k)
            CondSubj2Run(iF,iC) = 0;
        else
            CondSubj2Run(iF,iC) = k(1);
        end
    end
end




% ------------------------------------------------------------------
function CondNamesRunTbl = makeCondNamesRunTbl(runs, CondNamesRunTbl)

nRuns = length(runs);
if ~exist('CondNamesRunTbl','var')

    CondNamesRunTbl = cell(nRuns,1);
    for iR=1:nRuns
        CondNamesRunTbl{iR} = runs(iR).CondNames;
    end

else

    for iR=1:nRuns
        for iTbl=1:length(CondNamesRunTbl)
            if ~isempty(CondNamesRunTbl{iTbl}) && strcmp(CondNamesRunTbl{iTbl}{1}, runs(iR).name)
                 CondNamesRunTbl{iTbl} = runs(iR).CondNames;
            end
        end
    end

end

