% SD = enPruneChannels(d,SD,tInc,dRange,SNRthresh,SDrange,reset)
%
% UI NAME:
% Prune_Channels
%
%
% Prune channels from the measurement list if their signal is too weak, too
% strong, or their standard deviation is too great. This function
% updates SD.MeasListAct based on whether data 'd' meets these conditions
% as specified by'dRange' and 'SNRthresh'.
%
% INPUTS:
% d - data (nTpts x nChannels )
% SD - data structure describing the probe
% dRange - if mean(d) < dRange(1) or > dRange(2) then it is excluded as an
%      active channel
% SNRthresh - if mean(d)/std(d) < SNRthresh then it is excluded as an
%      active channel
% SDrange - will prune channels with a source-detector separation <
%           SDrange(1) or > SDrange(2)
% reset - reset previously pruned channels (automatic and manual)
%
% OUTPUTS:
% SD - data structure describing the probe
%
% TO DO:
% consider Conc as well as wavelength data
%

function SD = enPruneChannels(d,SD,tInc,dRange,SNRthresh,SDrange,resetFlag)


% Preset values
if nargin~=7
    disp( 'USAGE: enPruneChannels(d,SD,tInc,dRange,SNRthresh,resetFlag)' )
    return
end

lstInc = find(tInc==1);
d = d(lstInc,:);

%
if ~isfield(SD,'MeasListAct') | resetFlag==1
    SD.MeasListAct = ones(size(SD.MeasList,1),1);
end

% check for dRange and SNRthresh
dmean = mean(d,1);
dstd = std(d,[],1);

nLambda = length(SD.Lambda);
lst1 = find(SD.MeasList(:,4)==1);
for ii=1:nLambda
    lst = [];
    rhoSD = [];
    for jj=1:length(lst1)
        lst(jj) = find(SD.MeasList(:,1)==SD.MeasList(lst1(jj),1) & ...
            SD.MeasList(:,2)==SD.MeasList(lst1(jj),2) & ...
            SD.MeasList(:,4)==ii );
        rhoSD(jj) = norm( SD.SrcPos(SD.MeasList(lst1(jj),1),:) - SD.DetPos(SD.MeasList(lst1(jj),2),:) );
    end
    chanList(1:length(lst1),ii) = 0;
    lst2 = find(dmean(lst)>dRange(1) & dmean(lst)<dRange(2) & (dmean(lst)./dstd(lst))>SNRthresh & rhoSD>=SDrange(1) & rhoSD<=SDrange(2));
    chanList(lst2,ii) = 1; 
end
chanList = min(chanList,[],2);

% update SD.MeasListAct
SD.MeasListActAuto = ones(size(SD.MeasList,1),1);
SD.MeasListActAuto(find(chanList==0)) = 0;

SD.MeasListAct(find(chanList==0)) = 0;



