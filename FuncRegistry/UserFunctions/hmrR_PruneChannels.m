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

for iBlk = 1:length(data)
    
    d        = data(iBlk).GetDataTimeSeries();
    t        = data(iBlk).GetTime();
    MeasList = data(iBlk).GetMeasList();
    Lambda   = probe.GetWls();
    SrcPos   = probe.GetSrcPos();
    DetPos   = probe.GetDetPos();    
    
    mlActMan{iBlk} = mlAct_Initialize(mlActMan{iBlk}, MeasList);

    if isempty(tIncMan{iBlk})
        tIncMan{iBlk} = ones(length(t),1);
    end
    tInc = tIncMan{iBlk};
        
    lstInc = find(tInc==1);
    d = d(lstInc,:);

    % check for dRange and SNRthresh
    dmean = mean(d,1);
    dstd = std(d,[],1);
    
    idxs1 = [];
    idxs2 = [];
    idxs3 = [];
    nLambda = length(Lambda);
    lst1 = find(MeasList(:,4)==1);    

    % Start by including all channels
    chanList = ones(size(MeasList,1),1);
    
    for ii = 1:nLambda
        lst = [];
        rhoSD = [];
        for jj = 1:length(lst1)
            lst(jj) = find(MeasList(:,1)==MeasList(lst1(jj),1) & ...
                           MeasList(:,2)==MeasList(lst1(jj),2) & ...
                           MeasList(:,4)==ii);
            rhoSD(jj) = norm( SrcPos(MeasList(lst1(jj),1),:) - DetPos(MeasList(lst1(jj),2),:) );
        end
                
        % dRange exclusion criteria
        idxs1 = [idxs1, find(dmean(lst)<=dRange(1) | dmean(lst)>=dRange(2))];
        
        % SNRthresh exclusion criteria
        idxs2 = [idxs2, find((dmean(lst)./dstd(lst)) <= SNRthresh)];

        % SDrange exclusion criteria
        idxs3 = [idxs3, find(rhoSD<SDrange(1) | rhoSD>SDrange(2))];
        
        idxsExcl = unique([idxs1(:)', idxs2(:)', idxs3(:)']);
        
        chanList(lst(idxsExcl)) = 0;
    end
    
    idxs4 = find(mlActMan{iBlk}(:,3) == 0);
    
    if ~isempty(idxs1)
        fprintf('hmrR_PruneChannels:  excluded channels [ %s ] based on dRange=[ %s ] at wavelength %d\n', num2str(idxs1(:)'), num2str(dRange), ii);
    end
    if ~isempty(idxs2)
        fprintf('hmrR_PruneChannels:  excluded channels [ %s ] based on SNRthresh=%0.1f at wavelength %d\n', num2str(idxs2(:)'), SNRthresh, ii);
    end
    if ~isempty(idxs3)
        fprintf('hmrR_PruneChannels:  excluded channels [ %s ] based on SDrange=[ %s ] at wavelength %d\n', num2str(idxs3(:)'), num2str(SDrange), ii);
    end
    if ~isempty(idxs4)
        fprintf('hmrR_PruneChannels:  manually excluded channels [ %s ]\n', num2str(idxs4(:)'));
    end
    
    chanList = chanList(:) & mlActMan{iBlk}(:,3);
    
    % update MeasListAct  
    mlActAuto{iBlk} = mlAct_Initialize(chanList, MeasList);
end

