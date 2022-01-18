% SYNTAX:
% [data_dN, tInc, svs, nSV, tInc0] = hmrR_MotionCorrectPCArecurse(data_d, probe, mlActMan, mlActAuto, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh, nSV, maxIter, turnon)
%
%
% UI NAME:
% Motion_Correct_PCA_Recurse
%
%
% DESCRIPTION:
% This function uses PCA to iteratively filter the segments of data 
% identified as motion artifacts. After the correction, the residual 
% motion artefacts are re-identified and corrected again. The procedure is 
% repeated up to maxIter times. Set maxIter=0 to skip this function.
% 
% Motion artifacts are identified using hmrR_MotionArtifact function. If
% any active data channel exhibits a signal change greater than STDEVthresh
% or AMPthresh, then a segment of data around that time point is marked as 
% a motion artifact. The motion artifacts are indicated in the tInc vector
% by the value of 0. 
%
% PCA filter is only applied on the segments of data identified as a motion
% artifact. The number of principal components to remove is determined by 
% the nSV value. 
%
%
% INPUTS:
% data_d: data matrix, timepoints x sd pairs
% sd: Source Detector Structure. The active data channels are indicated in
%     SD.MeasListAct.
% mlActMan: Cell array of vectors, one for each time base in data, specifying
%        active/inactive channels with 1 meaning active, 0 meaning inactive
% mlActAuto: Cell array of vectors, one for each time base in data, specifying
%        active/inactive channels with 1 meaning active, 0 meaning inactive
% tIncMan: Data that has been manually excluded. 0-excluded, 1-included.
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
%     that AMPthresh over the time interval tMotion, then this time point
%     is marked as a motion artifact.
% nSV: Ranges between [0.0, 1.0] and determines the number of principal 
%      components to remove. PCA filter removes the first n components of the
%      data that removes a proportion of the variance up to nSV.
% maxIter: Maximum number of iterations. Yucel et al. uses maxIter=5;
%
%
% OUTPUTS:
% data_dN: This is the motion corrected data.
% tInc: a vector of length time points with 1's indicating data included
%       and 0's indicating motion artifact AFTER correction of motion
%       artifacts
% svs: the singular values of the PCA for each iteration in each column
%      vector
% nSV: number of singular values removed from the data.
% tInc0: a vector of length time points with 1's indicating data included
%       and 0's indicate motion artifact BEFORE correction of motion
%       artifacts
%
% USAGE OPTIONS:
% Motion_Correct_PCA_Recurse:  [dod, tInc, svs, nSV, tInc0] = hmrR_MotionCorrectPCArecurse(dod, probe, mlActMan, mlActAuto, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh, nSV, maxIter, turnon)
%
% PARAMETERS:
% tMotion: 0.5
% tMask: 1.0
% STDEVthresh: 20.0
% AMPthresh: 5.00
% nSV: 0.97 
% maxIter: 5 
% turnon: 1
%
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )
%

function [data_dN, tInc, svs, nSV, tInc0] = hmrR_MotionCorrectPCArecurse(data_d, probe, mlActMan,  mlActAuto, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh, nSV, maxIter, turnon)

nBlks = length(data_d);
for iBlk=1:nBlks
    data_dN(iBlk) = DataClass(data_d(iBlk));
end

% Initialize output 
tInc    = tIncMan;
svs     = cell(nBlks,1);
nSV     = repmat({nSV}, nBlks,1);
tInc0   = tIncMan;

% Check input args
if isempty(mlActMan)
    mlActMan = cell(nBlks,1);
end
if isempty(mlActAuto)
    mlActAuto = cell(nBlks,1);
end
if isempty(tIncMan)
    tIncMan = cell(nBlks,1);
end
if ~exist('turnon','var')
    turnon = 1;
end
if turnon==0
    return;
end

for iBlk=1:nBlks
    data_dN(iBlk) = DataClass(data_d(iBlk));
    
    tInc(iBlk) = hmrR_MotionArtifact(data_d(iBlk), probe, mlActMan(iBlk),  mlActAuto(iBlk), tIncMan(iBlk), tMotion, tMask, STDEVthresh, AMPthresh);

    tInc0{iBlk} = tInc{iBlk};
    
    ii=0;
    while length(find(tInc{iBlk}==0))>0 & ii<maxIter
        ii=ii+1;
        [data_dN(iBlk), svs_ii, nSV(iBlk)] = hmrR_MotionCorrectPCA(data_d(iBlk), mlActMan(iBlk), mlActAuto(iBlk), tIncMan(iBlk), tInc(iBlk), nSV(iBlk));
        tInc(iBlk) = hmrR_MotionArtifact(data_dN(iBlk), probe, mlActMan(iBlk), mlActAuto(iBlk), tIncMan(iBlk), tMotion, tMask, STDEVthresh, AMPthresh);
        data_d(iBlk).Copy(data_dN(iBlk));
        svs{iBlk}(:,ii) = svs_ii{1};
    end
end

