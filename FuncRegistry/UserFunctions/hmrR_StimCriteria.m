% SYNTAX:
% stim = hmrR_StimCriteria(stim, stimDataColIdx, logic, threshold)
%
% UI NAME:
% Stim_Apply_Criteria
%
% DESCRIPTION:
% Excludes stims based on the scalar values associated with them. A stim
% mark's onset, duration, or amplitude can be used. Additional scalar values
% defined in optional additional columns of the SNIRF stim data matrix can
% be used.
%
% INPUT: 
% stim:     SNIRF stim object
% stimDataColIdx: The stim data value to use as the criterion. Equivalent to
%           a column index into the SNIRF stim data matrix, i.e.
%           1. The stim onset time
%           2. The stim duration
%           3. The stim amplitude
%           Values of 4 and above select any additional columns of the 
%           SNIRF stim data matrix which may contain scalar values associated
%           with each stim mark.
% logic:    If 1, only stims which fall within the threshold range are enabled. 
%           If 0, only stims which outside the threshold range are enabled.
% threshold: The scalar values which bound the values of the selected stim
%           criterion.
%
% OUTPUT:
% stim:     SNIRF stim object
%
% USAGE OPTIONS:
% Stim_Apply_Criteria: stim = hmrR_StimCriteria(stim, stimDataColIdx, logic, threshold)
%
% PARAMETERS:
% stimDataColIdx: 1
% logic: 1
% threshold: [-1.00, 1.00]
%
function stim = hmrR_StimCriteria(stim, stimDataColIdx, logic, threshold)

% Exit if there are no stims
if isempty(stim)
    return;
end

% Exit if stimDataColIdx is too large for the stim data array
for i = 1:length(stim)
    if stimDataColIdx > size(stim(i).data, 2)
        return;
    end 
end

for i = 1:length(stim)
    if ~isempty(stim(i).data)
        stim(i).states(:, 2) = -2;  % Automatically disable all stims
        for j = 1:size(stim(i), 1)
            % If stim criterion is within threshold
            if stim(i).data(j, stimDataColIdx) > threshold(1) & stim(i).data(j, stimDataColIdx) < threshold(2)
                if logic
                    stim(i).states(j, 2) = 1;
                end
            else
                if ~logic
                    stim(i).states(j, 2) = 1; 
                end
            end
        end
    end
end

