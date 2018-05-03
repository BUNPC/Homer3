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
% tMask: Mark data over +/- tMask seconds around the identified motion 
%     artifact as a motion artifact. Units of seconds.
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
%      up to nSV.
% maxIter: Maximum number of iterations.
%
%
% OUTPUTS:
% dN: This is the the motion corrected data.
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact AFTER correction of motion
%       artifacts
% svs: the singular values of the PCA
% nSV: number of singular values removed from the data.
% tInc0: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact BEFORE correction of motion
%       artifacts
%

function [dN,tInc,svs,nSV,tInc0] = hmrMotionCorrectPCArecurse( d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh, nSV, maxIter )


tInc=hmrMotionArtifact(d, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
tInc0 = tInc;

dN = d;
svs = [];

ii=0;
while length(find(tInc==0))>0 & ii<maxIter
    [dN,svs,nSV] = hmrMotionCorrectPCA( SD, d, min([tInc tIncMan],[],2), nSV);
    tInc=hmrMotionArtifact(dN, fs, SD, tIncMan, tMotion, tMask, std_thresh, amp_thresh);
    ii=ii+1;
    d = dN;
end


