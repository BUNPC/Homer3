function [ REG, ADD ] = rtcca_dummy( X, AUX, param, flags )
% rtcca uses multimodal data, here fNIRS, acceleration and auxiliary signals, to
% extract regressors for GLM-based noise reduction using temporally embedded
% CCA regularized with shrinkage of covariance matrices with 'optimal' parameter from Ledoit & Wolf 2004

% This function is an adaptation of the BLISSARD artifact rejection code by
% Alexander von Luhmann, written in 2018 at TUB
% Main difference: CCA is performed with shrinked covariance matrices and
% is therefore implemented as generalized eigenvalue problem (in previous
% versions Matlab's canoncorr was used)
%
% INPUTS:
% X:    input nirs data with dimensions |time x channels|
% AUX:   input accel data with dimensions |time x channels|
%                    feeding in orthogonalized (PCA) data is advised.
% param.tau:  temporal embedding parameter (lag in samples)
% param.NumOfEmb: Number of temporally embedded copies
% param.ct:   correlation threshold. returns only those regressors that
%               have a canonical correlation greater than the threshold.
% flags.pcaf:  flags for performing pca of [AUX X] as preprocessing step.
%       default: [0 0]
% flags.shrink: regularize CCA with automatic shrinkage of covariance
%       matrices. default: true
%
% OUTPUTS:
% REG: Regressors found by temp. embedded CCA
% ADD.ccac: CCA correlation coefficients between projected fNIRS sources
%       and projected aux data
% ADD.aux_emb:   Temp. embedded accelerometer signals
% ADD.U,V:  sources in CCA space found by CCA
% ADD.gammaX,gammaAUX:  selected shrinkage parameters
% ADD.Av_red:   return (cca threshold) reduced mapping matrix Av


REG = round(100*rand(5,10));
ADD.Av = round(100*rand(5,10));
