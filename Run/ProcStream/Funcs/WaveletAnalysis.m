% function [ARSignal StatWT] = WaveletAnalysis(StatWT,L,wavename,iqr,SignalLength)
%
%
% Perform a wavelet motion correction of the dod data and computes the
% distribution of the wavelet coefficients. It sets the coefficient
% exceeding iqr times the interquartile range to zero, because these are probably due
% to motion artifacts. It applies the inverse discrete wavelet transform and
% reconstruct the signal. 
% 
% The algorithm follows in part the procedure described by
% Molavi et al.,Physiol Meas, 33, 259-270 (2012).
%
% INPUTS:
% StatWT:       matrix of wavelet coefficients (# of time points x # of
%               levels+1). The first column contains the approximation
%               coefficients, while the other all the details coefficients at
%               different levels
% L:            Lowest wavelet scale used in the analysis
% wavename:     name of the wavelet used in the reconstruction, should be the
%               same used in the previous decomposition
% iqr:          parameter used to compute the statistics (iqr = 1.5 means 1.5 times the
%               interquartile range and is usually used to detect outliers). 
%               Increasing it, it will delete less coefficients.
% SignalLength: Length of the original signal before zero padding
% 
%
% OUTPUTS:
% ARSIgnal:     signal reconstructed after the discrete inverse wavelet transform
%               and corrected for motion artifacts.
% StatWT:       matrix of wavelet coefficients corrected for motion
%               artifacts. Same size as StatWT input
%
% LOG:
% Script by Behnam Molavi bmolavi@ece.ubc.ca adapted for Homer2 by RJC
% modified 10/17/2012 by S. Brigadoi


function [ARSignal,StatWT]  = WaveletAnalysis(StatWT,L,wavename,iqr,SignalLength)

n=size(StatWT,1);       % Length of data vector with zero padding
N=log2(size(StatWT,1)); % Finest scale (original signal)
SignalLength_tmp = SignalLength;

for j=1:N-L-1
    SignalLength_tmp = fix(SignalLength_tmp/2);
    n_blocks = 2^j; % number of blocks in the level
    l_blocks = n/n_blocks; % length of the blocks in the level
    for b=0:(2^j-1)       
        sr = StatWT(b*l_blocks+1:b*l_blocks+l_blocks,j+1);
        
        sr_temp = sr(1:SignalLength_tmp); % compute statistics only on original data
        quants = quantile(sr_temp,[.25 .50 .75]);  % compute quantiles
        IQR = quants(3)-quants(1);  % compute interquartile range
        prob1 = quants(3)+IQR*iqr;
        prob2 = quants(1)-IQR*iqr; 
        outliers_1 = find(sr>prob1);
        outliers_2 = find(sr<prob2);
        outliers = [outliers_1' outliers_2'];
        sr(outliers) = 0;  % set outliers to 0
        StatWT(b*l_blocks+1:b*l_blocks+l_blocks,j+1) = sr;        
    end
end
ARSignal=IWT_inv(StatWT,wavename);  % reconstruct the signal with the discrete inverse wavelet transform
