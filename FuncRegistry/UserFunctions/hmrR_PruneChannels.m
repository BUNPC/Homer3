% SYNTAX:
% mlActAuto = hmrR_PruneChannels(data, probe, mlActMan, tInc, dRange, SNRthresh, SDrange)
%
% UI NAME:
% Prune_Channels
%
% DESCRIPTION:
% Prune channels from the measurement list if their signal is too weak, too
% strong, their signal-to-noise ratio (SNR) or standard deviation (SD) 
% is too great. This function outputs mlActAuto based on whether data meets
% the conditions specified by 'dRange', 'SNRthresh' and 'SDrange'.
%
% INPUTS:
% data - SNIRF object containing time course data (timepoints x channels)
% probe - SNIRF object describing the probe - optode positions and wavelengths
% mlActMan - cell array of vectors, specifying active/inactive channels 
%            with 1 meaning active, 0 meaning inactive 
% dRange - if mean(d) < dRange(1) or > dRange(2) then it is excluded as an
%          active channel
% SNRthresh - if mean(d)/std(d) < SNRthresh then it is excluded as an
%             active channel
% SDrange - will prune channels with a source-detector separation <
%           SDrange(1) or > SDrange(2)
%
% OUTPUTS:
% mlActAuto - cell array of vectors, one for each time base in data, 
%             specifying active/inactive channels with 1 meaning active, 0 meaning
%             inactive.
%                    
%
% USAGE OPTIONS:
% Prune_Channels: mlActAuto = hmrR_PruneChannels(data, probe, mlActMan, tIncMan, dRange, SNRthresh, SDrange)
%
% PARAMETERS:
% dRange: [1e4, 1e7]
% SNRthresh: 2
% SDrange: [0.0, 45.0]
%
% TO DO:
% consider Conc as well as wavelength data
%
function mlActAuto = hmrR_PruneChannels(data, probe, mlActMan, tIncMan, dRange, SNRthresh, SDrange)

% Init output 
mlActAuto = cell(length(data),1);

% Check input args
if nargin<7
    disp( 'USAGE: hmrR_PruneChannels(data, probe, mlActMan, tIncMan, dRange, SNRthresh, SDrange)' )
    return
end
if isempty(tIncMan)
    tIncMan = cell(length(data),1);
end
if isempty(mlActMan)
    mlActMan = cell(length(data),1);
end

for iBlk=1:length(data)
    
    d        = data(iBlk).GetDataTimeSeries();
    t        = data(iBlk).GetTime();
    MeasList = data(iBlk).GetMeasList();
    Lambda   = probe.GetWls();
    SrcPos   = probe.GetSrcPos();
    DetPos   = probe.GetDetPos();    
    if isempty(mlActMan{iBlk})
        mlActMan{iBlk} = ones(size(MeasList,1),1);
    end    
    MeasListAct = mlActMan{iBlk};
    if isempty(tIncMan{iBlk})
        tIncMan{iBlk} = ones(length(t),1);
    end
    tInc = tIncMan{iBlk};
        
    lstInc = find(tInc==1);
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
    
    mlActAuto{iBlk} = MeasListAct;
end

