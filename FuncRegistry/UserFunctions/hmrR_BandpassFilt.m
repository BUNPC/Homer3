% SYNTAX:
% data2 = hmrR_BandpassFilt( data, hpf, lpf )
%
% UI NAME:
% Bandpass_Filter
%
% DESCRIPTION:
% Perform a bandpass filter
%
% INPUT:
% data - SNIRF data type containing data time course to filter, time 
%       vector, and channels. 
% hpf - high pass filter frequency (Hz)
%       Typical value is 0 to 0.02.
% lpf - low pass filter frequency (Hz)
%       Typical value is 0.5 to 3.
%
% OUTPUT:
% data2 - SNIRF data type containing the filtered data time course, time 
%        vector, and channels. 
%
% USAGE OPTIONS:
% Bandpass_Filter: dod = hmrR_BandpassFilt( dod, hpf, lpf )
%
% PARAMETERS:
% hpf: [0.010]
% lpf: [0.500]
%

function [data2, ylpf] = hmrR_BandpassFilt( data, hpf, lpf )

% data is a handle object, make sure we don't change 
% it by working with a copy. 
data2 = data.copydeep();
if data.Empty()
    return;
end

for ii=1:length(data)
    
    y = data2(ii).GetD();
    fs = data2(ii).GetT();
    
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
    data2(ii).SetD(y2);
    
end

