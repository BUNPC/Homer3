% SYNTAX:
% [stim,tRange] = hmrR_StimRejection(data,stim,tIncAuto,tIncMan,tRange)
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
% data:     the time vector (#time points x 1)
% stim:     s matrix (#time points x #conditions) containing 1 for
%           each time point and condition that has a stimulus and
%           zeros otherwise.
% tIncAuto: time points (#time points x 1) identified as motion
%           artifacts by processing stream.
% tIncMan:  time points (#time points x 1) identified as motion
%           artifacts by user.
% tRange:   an array of 2 numbers [t1 t2] specifying how many
%           seconds surrounding motion artifacts, tIncMan and tIncAuto,
%           to consider as excluded data and therefore exclude any stimuli
%           which fall within those buffers.
%           Typically values are t1=-2 and t2 equal to the stimulus
%           duration.
%
% OUTPUT:
% stim:     s matrix (#time points x #conditions) containing 1 for
%           each time point and condition that has a stimulus that is
%           included in the HRF calculation, -1 for a stimulus that is
%           excluded automatically in the processing stream, -2
%           for each stimulus excluded by a manually set patch and
%           zeros otherwise.
% tRange:   same tRange array as in the input
%
% USAGE OPTIONS:
% Stim_Exclude: [stim,tRange] = hmrR_StimRejection(data,stim,tIncAuto,tIncMan,tRange)
%
% PARAMETERS:
% tRange: [-5.0, 10.0]
%
function [stim,tRange] = hmrR_StimRejection(data,stim,tIncAuto,tIncMan,tRange)

snirf = SnirfClass(data, stim);
for ii=1:length(snirf.data)
    t = snirf.data(ii).GetT();
    s = snirf.GetStims(ii);
    
    dt = (t(end)-t(1))/length(t);
    tRangeIdx = [floor(tRange(1)/dt):ceil(tRange(2)/dt)];
    
    smax = max(s,[],2);
    lstS = find(smax==1);
    for iS = 1:length(lstS)
        lst = round(min(max(lstS(iS) + tRangeIdx,1),length(t)));
        if ~isempty(tIncAuto) && min(tIncAuto(lst))==0
            s(lstS(iS),:) = -2*abs(s(lstS(iS),:));
        end
        if ~isempty(tIncMan) && min(tIncMan(lst))==0
            s(lstS(iS),:) = -1*abs(s(lstS(iS),:));
        end
    end
    snirf.SetStims_MatInput(s, t);
end
stim = snirf.stim;

