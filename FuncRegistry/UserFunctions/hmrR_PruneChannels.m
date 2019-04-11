% SYNTAX:
% mlAct = hmrR_PruneChannels(data, sd, mlActMan, tInc, dRange, SNRthresh, SDrange, reset)
%
% UI NAME:
% Prune_Channels
%
% DESCRIPTION:
% Prune channels from the measurement list if their signal is too weak, too
% strong, or their standard deviation is too great. This function
% updates MeasListAct based on whether data 'd' meets these conditions
% as specified by'dRange' and 'SNRthresh'.
%
% INPUTS:
% d - SNIRF object containing time course data (nTpts x nChannels )
% sd - SNIRF object describing the probe - optode positions and wavelengths.
% mlActMan - 
% dRange - if mean(d) < dRange(1) or > dRange(2) then it is excluded as an
%      active channel
% SNRthresh - if mean(d)/std(d) < SNRthresh then it is excluded as an
%      active channel
% SDrange - will prune channels with a source-detector separation <
%           SDrange(1) or > SDrange(2)
% reset - reset previously pruned channels (automatic and manual)
%
% OUTPUTS:
% mlAct - cell array of all data blocks - each data block is an array
%         of true/false for all channels in the contanining data block
%         specifying active/inactive status. (# of data blocks x # of Channels)
%
% USAGE OPTIONS:
% Prune_Channels: mlActAuto = hmrR_PruneChannels(data, sd, mlActMan, tIncMan, dRange, SNRthresh, SDrange, reset)
%
% PARAMETERS:
% dRange: [1e4, 1e7]
% SNRthresh: 2
% SDrange: [0.0, 45.0]
% reset: 0
%
% TO DO:
% consider Conc as well as wavelength data
%
function mlAct = hmrR_PruneChannels(data, sd, mlActMan, tIncMan, dRange, SNRthresh, SDrange, resetFlag)

mlAct = cell(length(data),1);

% Preset values
if nargin<7
    disp( 'USAGE: hmrR_PruneChannels(data, sd, mlActMan, tIncMan, dRange, SNRthresh, SDrange, resetFlag)' )
    return
end

for iBlk=1:length(data)
    
    d        = data(iBlk).GetD();
    t        = data(iBlk).GetT();
    MeasList = data(iBlk).GetMeasList();
    Lambda   = sd.GetWls();
    SrcPos   = sd.GetSrcPos();
    DetPos   = sd.GetDetPos();
    
    if isempty(mlActMan)
        MeasListAct = ones(size(MeasList,1),1);
    else
        MeasListAct = mlActMan{iBlk};        
    end
    
    if isempty(tIncMan)
        tInc = {ones(length(t),1)};
    else
        tInc = tIncMan{iBlk};        
    end
        
    lstInc = find(tInc{iBlk}==1);
    d = d(lstInc,:);

    % check for dRange and SNRthresh
    dmean = mean(d,1);
    dstd = std(d,[],1);
    
    nLambda = length(Lambda);
    lst1 = find(MeasList(:,4)==1);
    for ii=1:nLambda
        lst = [];
        rhoSD = [];
        for jj=1:length(lst1)
            lst(jj) = find(MeasList(:,1)==MeasList(lst1(jj),1) & ...
                           MeasList(:,2)==MeasList(lst1(jj),2) & ...
                           MeasList(:,4)==ii);
            rhoSD(jj) = norm( SrcPos(MeasList(lst1(jj),1),:) - DetPos(MeasList(lst1(jj),2),:) );
        end
        chanList(1:length(lst1),ii) = 0;
        lst2 = find(dmean(lst)>dRange(1) & dmean(lst)<dRange(2) & (dmean(lst)./dstd(lst))>SNRthresh & rhoSD>=SDrange(1) & rhoSD<=SDrange(2));
        chanList(lst2,ii) = 1;
    end
    chanList = min(chanList,[],2);
    
    % update MeasListAct
    MeasListAct(find(chanList==0)) = 0;
    
    mlAct{iBlk} = MeasListAct;
end

