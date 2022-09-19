% SYNTAX:
% data_d = hmrR_MotionCorrectSplineSG_sim(data_d, mlActAuto, p, FrameSize_sec, turnon)
%
% UI NAME:
% SplineSG_Motion_Correction
%
% DESCRIPTION:
% The function first identifies the baseline shifts and spikes in the signal. The baseline shifts are corrected using
% a spline interpolation method. The remaining spikes are corrected by Savitzky-Golay filtering, which is a digital smoothing filter
% that substitutes each value of the signal series with a new value obtained by applying a cubic fitting to a subset of adjacent data points.
% The length of the subset is defined by the parameter FrameSize_sec.
% The method is described in the following paper.
% Citation: Jahani et al., Neurophotonics, 2018; doi: 10.1117/1.NPh.5.1.015003. 
% 
% INPUTS:
% data_d:        SNIRF object containing time course data
% mlActAuto:
% p:             Parameter p used in the spline interpolation. The value
%                recommended in the literature is 0.99. Use -1 if you want to skip this
%                motion correction.
% FrameSize_sec: The step lenght in seconds that a least-squares minimization will be applied using a cubic Savitzky-Golay filter.  
% turnon:        Optional argument to enable/disable this function in a processing stream chain
%
% OUTPUTS:
% data_d:        SNIRF object containing time course data after spline interpolation correction
%
% USAGE OPTIONS:
% SplineSG_Motion_Correction: dod = hmrR_MotionCorrectSplineSG_sim(dod, mlActAuto, p, FrameSize_sec, turnon)
%
% PARAMETERS:
% p: 0.99
% FrameSize_sec: 10
% turnon: 1
%
% 
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )
%
% LOG:
% Sahar Jahani, October 2017

function data_d = hmrR_MotionCorrectSplineSG_sim(data_d, mlActAuto, p, FrameSize_sec, turnon)

if ~exist('turnon','var')
   turnon = 1;
end
if turnon==0
    return;
end
if isempty(mlActAuto)
    mlActAuto = cell(length(data_d),1);
end

for iBlk = 1:length(data_d)

    dod = data_d(iBlk).GetDataTimeSeries();               
    data_d(iBlk).SetDataTimeSeries(dod);
    
end

