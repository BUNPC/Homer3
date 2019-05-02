% SYNTAX:
% data_d = hmrR_MotionCorrectSplineSG(data_d, mlActAuto, p, FrameSize_sec, turnon)
%
% UI NAME:
% SplineSG_Motion_Correction
%
% DESCRIPTION:
% Perform a cubic spline correction of the motion artifacts identified in
% tIncCh. The algorithm follows the procedure describe by
% Scholkmann et al., Physiol. Meas. 31, 649-662 (2010). Set p = -1 to skip
% this function.
%
% INPUTS:
% data_d:        SNIRF object containing time course data
% mlActAuto:
% p:             Parameter p used in the spline interpolation. The value
%                recommended in the literature is 0.99. Use -1 if you want to skip this
%                motion correction.
% FrameSize_sec:
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
% LOG:
% Sahar Jahani, October 2017
% Added turn on/off option Meryem Nov 2017

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

for iBlk=1:length(data_d)

    dod             = data_d(iBlk).GetDataTimeSeries();
    t               = data_d(iBlk).GetTime();
    SD.MeasList     = data_d(iBlk).GetMeasList();
    if isempty(mlActAuto{iBlk})
        mlActAuto{iBlk} = ones(size(SD.MeasList,1),1);
    end    
    SD.MeasListAct  = mlActAuto{iBlk};
    
    [tIncCh, tInc] = hmrR_tInc_baselineshift_Ch_Nirs(dod, t); % finding the baseline shift motions
    
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
    
    [dodLP, ylpf] = hmrR_BandpassFilt_Nirs(dod, fs, 0, 2);
    
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

    data_d(iBlk).SetDataTimeSeries(dod);
end

