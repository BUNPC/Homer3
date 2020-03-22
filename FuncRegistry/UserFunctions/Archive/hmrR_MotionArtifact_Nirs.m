% SYNTAX:
% tInc = hmrR_MotionArtifact_Nirs(d, fs, SD, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh)
%
% UI NAME:   
% Motion_Artifacts
%
% DESCRIPTION:
% Identifies motion artifacts in an input data matrix d. If any active 
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact.
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
%     Typical value ranges from 0.1 to 0.5.
% tMask: Mark data over +/- tMask seconds around the identified motion 
%     artifact as a motion artifact. Units of seconds. 
%     Typical value ranges from 0.5 to 1.
% STDEVthresh: If the signal d for any given active channel changes by more
%     that stdev_thresh * stdev(d) over the time interval tMotion, then
%     this time point is marked as a motion artifact. The standard deviation is
%     determined for each channel independently.
%     Typical value ranges from 5 to 20. Use a value of 100 or greater if
%     you wish for this condition to not find motion artifacts.
% AMPthresh: If the signal d for any given active channel changes by more
%     that amp_thresh over the time interval tMotion, then this time point
%     is marked as a motion artifact.
%     Typical value ranges from 0.01 to 0.3 for optical density units. Use
%     a value greater than 100 if you wish for this condition to not find
%     motion artifacts.
%
%
% OUTPUTS:
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact
%
% USAGE OPTIONS:
% Motion_Artifacts_By_Channel:  tIncAuto = hmrR_MotionArtifact_Nirs(dod, t, SD, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh)
%
% PARAMETERS:
% tMotion: 0.5
% tMask: 1.0
% STDEVthresh: 50.0
% AMPthresh: 5.0
% 
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

function tInc = hmrR_MotionArtifact_Nirs(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh)

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
else
    tIncMan = tIncMan{1};
end
tInc = tIncMan;

% Calculate the diff of d to to set the threshold if ncssesary
diff_d=diff(d);

% set artifact buffer for tMask seconds on each side of spike
art_buffer=round(tMask*fs); % time in seconds times sample rate

% get list of active channels
lstAct = zeros(size(SD.MeasList,1),1);
nLambda = length(SD.Lambda);
lst1 = find(SD.MeasList(:,4)==1);
for ii=1:nLambda
    for jj=1:length(lst1)
        lst(jj) = find(SD.MeasList(:,1)==SD.MeasList(lst1(jj),1) & ...
            SD.MeasList(:,2)==SD.MeasList(lst1(jj),2) & ...
            SD.MeasList(:,4)==ii );
        lstAct(lst(jj)) = SD.MeasListAct(jj);
    end
end
lstAct = find(lstAct==1);

% calculate std_diff for each channel
std_diff=std(d(2:end,lstAct)-d(1:end-1,lstAct),0,1);

% calculate max_diff across channels for different time delays
max_diff = zeros(size(d,1)-1,length(lstAct));
for ii=1:round(tMotion*fs)
    max_diff=max([abs(d((ii+1):end,lstAct)-d(1:(end-ii),lstAct)); zeros(ii-1,length(lstAct))], max_diff);
end

% find indices with motion artifacts based on std_thresh or amp_thresh
bad_inds = [];
mc_thresh=std_diff*std_thresh;
bad_inds = find( max(max_diff > ones(size(max_diff,1),1)*mc_thresh ,[],2)==1 | ...
    max(max_diff,[],2) > amp_thresh  );

% Eliminate time points before or after motion artifacts
if ~isempty(bad_inds)
    bad_inds=repmat(bad_inds, 1, 2*art_buffer+1)+repmat(-art_buffer:art_buffer,length(bad_inds), 1);
    bad_inds=bad_inds((bad_inds>0)&(bad_inds<=(size(d, 1)-1)));
    
    % exclude points that were manually excluded
    bad_inds(find(tIncMan(bad_inds)==0)) = [];
    
    % Set t and diff of data to 0 at the bad inds
    tInc(1+bad_inds)=0; % bad inds calculated on diff so add 1
    
end

% calculate the variance due to motion relative to total variance
lst = find(tInc==0);
dstd0 = std(d(lst,:),[],1);
lst = find(tInc==1);
dstd1 = std(d(lst,:),[],1);

end


