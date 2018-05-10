% [dN,tInc,dstd,svs,nSV,tInc0] = hmrMotionCorrectPCArecurse( d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh, nSV )
%
%
% UI NAME
% Motion_Correct_PCA_Recurse
%
%
% Identified motion artifacts in an input data matrix d. If any active 
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact. Set maxIter=0 to skip this function.
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
%     time range tMotion. Units of seconds. Typically tMotion=0.5.
% tMask: Mark data over +/- tMask seconds around the identified motion 
%     artifact as a motion artifact. Units of seconds. Typicall tMask=1.
% STDEVthresh: If the signal d for any given active channel changes by more
%     that stdev_thresh * stdev(d) over the time interval tMotion, then
%     this time point is marked as a motion artifact. The standard deviation is
%     determined for each channel independently.
% AMPthresh: If the signal d for any given active channel changes by more
%     that amp_thresh over the time interval tMotion, then this time point
%     is marked as a motion artifact.
% nSV: This is the number of principal components to remove from the data.
%      If this number is less than 1, then the filter removes the first n
%      components of the data that removes a fraction of the variance
%      up to nSV. Yucel et al uses nSV=0.97.
% maxIter: Maximum number of iterations. Yucel et al uses maxIter=5;
%
%
% OUTPUTS:
% dN: This is the the motion corrected data.
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact AFTER correction of motion
%       artifacts
% svs: the singular values of the PCA for each iteration in each column
%      vector
% nSV: number of singular values removed from the data.
% tInc0: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact BEFORE correction of motion
%       artifacts
% LOGS:
% This function performs tPCA and splice the segments of data together in
% two different ways (either using one tInc for all channels or using
% tIncCh), compares the results and picks the good one for a specific channel. Meryem Oct 2017

function [dN,tInc,svs,nSV,tInc0] = hmrMotionCorrectPCArecurse_Ch_dual( d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh, nSV, maxIter, turnon )

if exist('turnon')
   if turnon==0
       dN = d;
       tInc = tIncMan;
       svs = [];
       tInc0 = [tIncMan];      
   return;
   end
end


%% tPCA by channel
dorig = d;
nSVorig = nSV;

tInc=hmrMotionArtifact(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
[X,tIncCh] = hmrMotionArtifactByChannel(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
tInc0 = tInc;

dN = d;
svs = [];
mlAct = SD.MeasListAct; 
lstAct = find(mlAct==1);

ii=0;
while length(find(tInc==0))>0 & ii<maxIter
    ii=ii+1;
    [dN,svs(:,ii),nSV] = hmrMotionCorrectPCA_Ch( SD, d, min([tInc tIncMan],[],2),  tIncCh, nSV);
    tInc = hmrMotionArtifact(dN, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
    [X,tIncCh] = hmrMotionArtifactByChannel(dN, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
    d = dN;
end
d1 = d;
clear tInc tIncCh svs 

%% original tPCA
d = dorig ;
nSV = nSVorig;

tInc=hmrMotionArtifact(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
tInc0 = tInc;
dN = d;
svs = [];

ii=0;
while length(find(tInc==0))>0 & ii<maxIter
    ii=ii+1;
    [dN,svs(:,ii),nSV] = hmrMotionCorrectPCA( SD, d, min([tInc tIncMan],[],2), nSV);
    tInc=hmrMotionArtifact(dN, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
    d = dN;
end
d2 = d;
d2(end,:)=d2(end-1,:);


%% get the best performing one for each channel
y1 = hmrBandpassFilt( d1, fs, 0.01, 0.5 );
y2 = hmrBandpassFilt( d2, fs, 0.01, 0.5 );
foo = std(y1)-std(y2);

d = d2;
lst = find(foo<=0);
for i = 1:size(lst,2); d(:,lst(i)) = d1(:,lst(i)); end
dN=d;

