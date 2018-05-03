function group = UpdateGroupSD(group)

% 
% USAGE:
%
%   group = UpdateGroupSD(group)
%
%
% DESCRIPTION:
%
%   Function goes through group and checks that SD.MeasListAct for group and
%   subjects is consistent with the SD.MeasListAct for the all runs under them. 
% 
%   So for example if channel X was manually excluded at the group level, then 
%   channel X will be excluded for all the subjects and all the runs. 
% 
%   However if the user then toggles channel X back to include it for run i
%   of subject j, then the group level exclusion will no longer accurately
%   refleft that not all the run under it have this exlusion. 
%
%   This function goes through all the subjects and runs and checks that the
%   channels shown as excluded at the group and subject levels only exlude
%   channels for which the ALL the runs under them exlcude that channel. 
%
%

MeasListActSubjs = zeros(length(group(1).SD.MeasListAct), length(group(1).subjs));
for jj=1:length(group(1).subjs)
    MeasListActRuns = zeros(length(group(1).SD.MeasListAct), length(group(1).subjs(jj).runs));
    for kk=1:length(group(1).subjs(jj).runs)
        MeasListActRuns(:,kk) = group(1).subjs(jj).runs(kk).SD.MeasListAct;
    end
    group(1).subjs(jj).SD.MeasListAct = ~all(MeasListActRuns==0, 2);
    MeasListActSubjs(:,jj) = group(1).subjs(jj).SD.MeasListAct;
end
group(1).SD.MeasListAct = ~all(MeasListActSubjs==0, 2);

