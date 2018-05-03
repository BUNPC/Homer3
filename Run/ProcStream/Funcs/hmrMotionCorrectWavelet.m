% function dodWavelet = hmrMotionCorrectWavelet(dod,SD,iqr)
%
% UI NAME:
% Wavelet_Motion_Correction
%
% Perform a wavelet transformation of the dod data and computes the
% distribution of the wavelet coefficients. It sets the coefficient
% exceeding iqr times the interquartile range to zero, because these are probably due
% to motion artifacts. 
% 
% The algorithm follows in part the procedure described by
% Molavi et al.,Physiol Meas, 33, 259-270 (2012).
%
% INPUTS:
% dod:   delta_OD 
% SD:    SD structure
% iqr    parameter used to compute the statistics (iqr = 1.5 is 1.5 times the
%        interquartile range and is usually used to detect outliers). 
%        Increasing it, it will delete fewer coefficients.
%        If iqr<0 then this function is skipped.
% 
%
% OUTPUTS:
% dodWavelet:  dod after wavelet motion correction, same
%              size as dod (Channels that are not in the active ml remain unchanged)
%
% LOG:
% Script by Behnam Molavi bmolavi@ece.ubc.ca adapted for Homer2 by RJC
% modified 10/17/2012 by S. Brigadoi
%


function [dodWavelet] = hmrMotionCorrectWavelet(dod,SD,iqr)

if iqr<0
    dodWavelet = dod;
    return;
end

mlAct = SD.MeasListAct; % prune bad channels

lstAct = find(mlAct==1);
dodWavelet = dod;

SignalLength = size(dod,1); % #time points of original signal
N = ceil(log2(SignalLength)); % #of levels for the wavelet decomposition
DataPadded = zeros (2^N,1); % data length should be power of 2  
load db2;  % Load a wavelet (db2 in this case)
qmfilter = qmf(db2,4); % Quadrature mirror filter used for analysis
L = 4;  % Lowest wavelet scale used in the analysis

for ii = 1:length(lstAct)
    
    idx_ch = lstAct(ii);

    DataPadded(1:SignalLength) = dod(:,idx_ch);  % zeros pad data to have length of power of 2   
    DataPadded(SignalLength+1:end) = 0;  
    
    DCVal = mean(DataPadded);         
    DataPadded = DataPadded-DCVal;    % removing mean value
    DataLength = size(DataPadded,1);  
   
    [yn NormCoef]=NormalizationNoise(DataPadded',qmfilter);
    
    StatWT = WT_inv(yn,L,N,'db2'); % discrete wavelet transform shift invariant

    [ARSignal wcTI] = WaveletAnalysis(StatWT,L,'db2',iqr,SignalLength);  % Apply artifact removal
       
    ARSignal = ARSignal/NormCoef+DCVal;           

    dodWavelet(:,idx_ch) = ARSignal(1:length(dod));

end