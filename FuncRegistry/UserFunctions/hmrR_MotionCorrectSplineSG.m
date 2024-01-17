% SYNTAX:
% data_d = hmrR_MotionCorrectSplineSG(data_d, mlActAuto, p, FrameSize_sec, turnon)
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
% SplineSG_Motion_Correction: dod = hmrR_MotionCorrectSplineSG(dod, mlActAuto, p, FrameSize_sec, turnon)
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

function data_d = hmrR_MotionCorrectSplineSG(data_d, mlActAuto, p, FrameSize_sec, turnon)

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

    [dod, t, SD.MeasList, order] = data_d(iBlk).GetDataTimeSeries('matrix : reshape : wavelength');
    dod = dod(:,:);
    
    mlActAuto{iBlk} = mlAct_Initialize(mlActAuto{iBlk}, SD.MeasList);
    SD.MeasListAct  = mlAct_Matrix2BinaryVector(mlActAuto{iBlk}, SD.MeasList);
    
    tIncCh = hmrR_tInc_baselineshift_Ch_Nirs(dod, t); % finding the baseline shift motions
    
    fs = abs(1/(t(2)-t(1)));
    
    % extending signal for motion detection purpose (12 sec from each edge)
    extend = round(12*fs);
    
    tIncCh1 = repmat(tIncCh(1,:),extend,1);
    tIncCh2 = repmat(tIncCh(end,:),extend,1);
    tIncCh  = [tIncCh1;tIncCh;tIncCh2];
    
    d1 = repmat(dod(1,:),extend,1);
    d2 = repmat(dod(end,:),extend,1);
    dod = [d1;dod;d2];
    
    t2 = (0:(1/fs):(length(dod)/fs))';
    t2 = t2(1:length(dod),1);
    
    dodLP = hmrR_BandpassFilt_Nirs(dod, fs, 0, 2);
    
    %%%% Spline Interpolation
    dod = hmrR_MotionCorrectSpline_Nirs(dodLP, t2, SD, tIncCh, p);
    dod = dod(extend+1:end-extend,:); % removing the extention
    
    %%%% Savitzky_Golay filter
    K = 3; % polynomial order
    FrameSize_sec = round(FrameSize_sec * fs);
    if mod(FrameSize_sec,2)==0
        FrameSize_sec = FrameSize_sec  + 1;
    end
    dod = sgolayfilt(dod,K,FrameSize_sec);

    dod(:,order) = dod(:,:);
    data_d(iBlk).SetDataTimeSeries(dod);
    
end

