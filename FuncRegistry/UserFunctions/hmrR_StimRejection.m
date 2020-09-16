% SYNTAX:
% [stimStatus, tRange] = hmrR_StimRejection(data, stimStatus, tIncAuto, tIncMan, tRange)
%
% UI NAME:
% Stim_Exclude
%
% DESCRIPTION:
% Excludes stims that fall within the time points identified as
% motion artifacts from HRF calculation.
%
%
% INPUT:
% data:     SNIRF data object    
% stimStatus: ProcInputClass.stimStatus cell array of time and status per
% stim mark per condition
% tIncAuto: Cell array of length equal to the # of time bases in data. Each 
%           cell element is time points (#time points x 1) identified as motion
%           artifacts by processing stream.
% tIncMan:  Cell array of length equal to the # of time bases in data. Each 
%           cell element is time points (#time points x 1) identified as motion
%           artifacts by user.
% tRange:   an array of 2 numbers [t1 t2] specifying how many
%           seconds surrounding motion artifacts, tIncMan and tIncAuto,
%           to consider as excluded data and therefore exclude any stimuli
%           which fall within those buffers.
%           Typically values are t1=-2 and t2 equal to the stimulus
%           duration.
%
% OUTPUT:
% stimStatus: ProcInputClass.stimStatus with disabled stims
% tRange:   same tRange array as in the input
%
% USAGE OPTIONS:
% Stim_Exclude: [stimStatus,tRange] = hmrR_StimRejection(dod,stimStatus,tIncAuto,tIncMan,tRange)
%
% PARAMETERS:
% tRange: [-5.0, 10.0]
%
function [stimStatus, tRange] = hmrR_StimRejection(data, stimStatus, tIncAuto, tIncMan, tRange)

if isempty(tIncAuto)
    tIncAuto = cell(length(data),1);
end
if isempty(tIncMan)
    tIncMan = cell(length(data),1);
end

% Get stim time by instantiating temporary SnirfClass object with this 
% function's data argument, calling GetTimeCombined method
snirf = SnirfClass(data);

for iBlk=1:length(snirf.data)  % For each data block
    t = snirf.data(iBlk).GetTime();
    % Interpolate stim status signal onto t, reject stims with tIncMan or
    % tIncAuto values of 0
    for i = 1:length(stimStatus)  % For each condition
        status = stimStatus{i};
        if ~isempty(status)
            for j = 1:length(status(:,1))  % For each mark in each condition
                % Find index k of stim mark in time series t
                k = find(abs(t - status(j,1)) < 1e-3); % Error margin is const
                % Check if stims are excluded by time series
                if ~isempty(tIncAuto{iBlk})
                    if tIncAuto{iBlk}(k) == 0 
                        status(j, 2) = -2;
                    end
                end
                if ~isempty(tIncMan{iBlk})  % Manual rejection takes precedence
                    if tIncMan{iBlk}(k) == 0
                        status(j, 2) = -1;
                    end
                end
            end            
        end
    end
end

end

