% SYNTAX:
% [stim, tRange] = hmrR_StimRejection(data, stim, tIncAuto, tIncMan, tRange)
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
% stim:     SNIRF stim object
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
% stim:     SNIRF stim object
% tRange:   same tRange array as in the input
%
% USAGE OPTIONS:
% Stim_Exclude: [stim,tRange] = hmrR_StimRejection(dod,stim,tIncAuto,tIncMan,tRange)
%
% PARAMETERS:
% tRange: [-5.0, 10.0]
%
function [stim, tRange] = hmrR_StimRejection(data, stim, tIncAuto, tIncMan, tRange)

if isempty(tIncAuto)
    tIncAuto = cell(length(data),1);
end
if isempty(tIncMan)
    tIncMan = cell(length(data),1);
end

snirf = SnirfClass(data, stim);
for iBlk=1:length(snirf.data)
    t = snirf.data(iBlk).GetTime();
    s = snirf.GetStims(t);
    
    dt = (t(end)-t(1))/length(t);
    tRangeIdx = [floor(tRange(1)/dt):ceil(tRange(2)/dt)];
    
    smax = max(s,[],2);
    lstS = find(smax==1);
    for iS = 1:length(lstS)
        lst = round(min(max(lstS(iS) + tRangeIdx,1),length(t)));
        if ~isempty(tIncAuto{iBlk}) && min(tIncAuto{iBlk}(lst))==0
            s(lstS(iS),:) = -2*abs(s(lstS(iS),:));
        end
        if ~isempty(tIncMan{iBlk}) && min(tIncMan{iBlk}(lst))==0
            s(lstS(iS),:) = -1*abs(s(lstS(iS),:));
        end
    end
    snirf.SetStims_MatInput(s, t);
end
stim = snirf.stim;

