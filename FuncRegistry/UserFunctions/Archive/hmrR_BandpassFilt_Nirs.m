% SYNTAX:
% y2 = hmrR_BandpassFilt_Nirs( y, fs, hpf, lpf )
%
% UI NAME:
% Bandpass_Filter
%
% DESCRIPTION:
% Perform a bandpass filter
%
% INPUT:
% y - data to filter #time points x #channels of data
% fs - sample frequency (Hz). If length(fs)>1 then this is assumed to be a time
%      vector from which fs is estimated
% hpf - high pass filter frequency (Hz)
%       Typical value is 0 to 0.02.
% lpf - low pass filter frequency (Hz)
%       Typical value is 0.5 to 3.
%
% OUTPUT:
% y2 - filtered data
%
% USAGE OPTIONS:
% Bandpass_Filter_OpticalDensity: dod = hmrR_BandpassFilt(dod, t, hpf, lpf)
% Bandpass_Filter_Auxiliary: aux = hmrR_BandpassFilt(aux, t, hpf, lpf)
%
% PARAMETERS:
% hpf: [0.010]
% lpf: [0.500]
%

function [y2,ylpf] = hmrR_BandpassFilt_Nirs( y, fs, hpf, lpf )

% convert t to fs
% assume fs is a time vector if length>1
if length(fs)>1
    fs = 1/(fs(2)-fs(1));
end

% low pass filter
FilterType = 1;
FilterOrder = 3;
%[fa,fb]=butter(FilterOrder,lpf*2/fs);
if FilterType==1 | FilterType==5
    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low');
elseif FilterType==4
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low',Filter_Rp,Filter_Rs);
else
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,lpf,'low',Filter_Rp);
end
ylpf=filtfilt(fb,fa,y);

% high pass filter
FilterType = 1;
FilterOrder = 5;
if FilterType==1 | FilterType==5
    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high');
elseif FilterType==4
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high',Filter_Rp,Filter_Rs);
else
%    [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,hpf,'high',Filter_Rp);
end

if FilterType~=5
    y2=filtfilt(fb,fa,ylpf); 
else
    y2 = ylpf;
end
