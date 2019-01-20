% [tInc,tIncCh] = hmrMotionArtifactByChannel(d, fs, SD, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh)
%
% UI NAME:   
% Motion_Artifacts_By_Channel
%
%
% Identifies motion artifacts in an input data matrix d. If any active 
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact. The channel-wise motion artifacts are recorded in the
% output matrix tIncCh. If any channel has a motion artifact, it is
% indicated by the vector tInc.
%
%
% INPUTS:
% d: data matrix, timepoints x sd pairs
% fs: sample frequency in Hz. You can send the time vector and fs will be
%     calculated
% SD: Source Detector Structure. The active data channels are indicated in
%     SD.MeasListAct.
% tIncMan: Data that has been manually excluded. 0-excluded. 1-included.
%          Vector same length as d.
% tMotion: Check for signal change indicative of a motion artifact over
%     time range tMotion. Units of seconds.
% tMask: Mark data over +/- tMask seconds around the identified motion 
%     artifact as a motion artifact. Units of seconds.
% STDEVthresh: If the signal d for any given active channel changes by more
%     that stdev_thresh * stdev(d) over the time interval tMotion, then
%     this time point is marked as a motion artifact. The standard deviation is
%     determined for each channel independently.
% AMPthresh: If the signal d for any given active channel changes by more
%     that amp_thresh over the time interval tMotion, then this time point
%     is marked as a motion artifact.
%
%
% OUTPUTS:
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact
% tIncCh: a matrix with #time points x #channels, with 1's indicating data
%       included and 0's indicating motion artifacts on a channel by
%       channel basis
%
% LOG:
% K. Perdue
% kperdue@nmr.mgh.harvard.edu
% Sept. 23, 2010
% Modified by DAB 3/17/2011 to not act on a single channel by default
% DAB 4/20/2011 added tMotion and tMask and hard coded stdev option.
% DAB 8/4/2011 added amp_thresh to work at same time as std_thresh
%
% TO DO:
% Consider tIncMan

function [tInc,tIncCh] = hmrMotionArtifactByChannel(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh)

% Input processing.  Check required inputs, throw errors if necessary.
if nargin<3
    error('Must use inputs d, fs, SD.  See help MC for details.')
end

if ~isnumeric(d)
    error('Must use matrix input d.  See help MC for details.')
end

if ~isnumeric(fs)
    error('Must use numeric input fs for sampling frequency.  See help MC for details.')
end

if length(fs)~=1 && length(fs)~=size(d,1)
    error('fs must either be sample frequency or a time vector with same length as d')
end
if length(fs)~=1
    fs = 1/(fs(2)-fs(1));
end

if isempty(tIncMan)
    tIncMan = ones(size(d,1),1);
end

tInc = ones(size(d,1),1);
tIncCh = ones(size(d,1),size(SD.MeasList,1));

% Calculate the diff of d to to set the threshold if ncssesary
diff_d=diff(d);



% set artifact buffer for tMask seconds on each side of spike
art_buffer=round(tMask*fs); % time in seconds times sample rate

lstAct = find(SD.MeasListAct==1);

% LOOP OVER CHANNELS
for iCh = 1:length(lstAct)
    
    % calculate std_diff for each channel
    std_diff=std(d(2:end,lstAct(iCh))-d(1:end-1,lstAct(iCh)),0,1);
    
    % calculate max_diff across channels for different time delays
    max_diff = zeros(size(d,1)-1,1);
    for ii=1:round(tMotion*fs)
        max_diff=max([abs(d((ii+1):end,lstAct(iCh))-d(1:(end-ii),lstAct(iCh))); zeros(ii-1,1)], max_diff);
    end
    
    % find indices with motion artifacts based on std_thresh or amp_thresh
    bad_inds = [];
    mc_thresh=std_diff*std_thresh;
    bad_inds = find( max(max_diff > mc_thresh ,[],2)==1 | ...
        max_diff > amp_thresh  );
    
    % Eliminate time points before or after motion artifacts
    if ~isempty(bad_inds)
        bad_inds=repmat(bad_inds, 1, 2*art_buffer+1)+repmat(-art_buffer:art_buffer,length(bad_inds), 1);
        bad_inds=bad_inds((bad_inds>0)&(bad_inds<=(size(d, 1)-1)));
        
        % exclude points that were manually excluded
        bad_inds(find(tIncMan(bad_inds)==0)) = [];
        
        % Set t and diff of data to 0 at the bad inds
        tInc(1+bad_inds)=0; % bad inds calculated on diff so add 1
        tIncCh(1+bad_inds,lstAct(iCh)) = 0;
    end
    
end % loop over channels


% calculate the variance due to motion relative to total variance
lst = find(tInc==0);
dstd0 = std(d(lst,:),[],1);
lst = find(tInc==1);
dstd1 = std(d(lst,:),[],1);

end





% Function to find the sd pair with the largest spikes
function sd_pair=find_sd(diff_d)
[max_diff, max_ind]=max(max(diff_d));
sd_pair=max_ind;
end
