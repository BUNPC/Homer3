% [dc, dod] = hmrIntensity2Conc( d, SD, fs, hpf, lpf, ppf )
%
% UI NAME:
% Intensity_to_Concentration
%
%
% This function will convert raw nirs data to concentrations. It will
% convert raw signals to Delta OD, bandpass filter, and convert Delta 
% OD to Delta Concentrations. 
%
% INPUT:
% d - intensity data (#time points x #channels)
% SD - the SD structure
% fs - sample frequency (Hz). If length(fs)>1 then this is assumed to be a time
%      vector from which fs is estimated
% hpf - high pass filter frequency (Hz)
% lpf - low pass filter frequency (Hz)
% ppf - partial pathlength factor
%
% OUTPUT:
% dc - the concentration data (#time points x 3 x #SD pairs
%      3 concentrations are returned (HbO, HbR, HbT)
% dod - the change in optical density
%
% DEPENDENCIES:
% hmrIntensity2OD, hmrBandpassFilt and hmrOD2Conc.
%
% TO DO:
% generalize to N wavelengths (don't assume N=2)

function [dc, dod] = hmrIntensity2Conc( d, SD, fs, hpf, lpf, ppf )

% error check
if ~exist('ppf')
    ppf = [];
end
if length(ppf)~=length(SD.Lambda)
    disp( sprintf('Warning: ppf must be a vector with the same number of elements as SD.Lambda\n    Using default values of [6 6]') );
    ppf = [6 6];
end

% convert Intensity to dOD
dod = hmrIntensity2OD( d );

% bandpass filter
dod = hmrBandpassFilt( dod, fs, hpf, lpf );

% convert to Concentrations
dc = hmrOD2Conc( dod, SD, ppf );

