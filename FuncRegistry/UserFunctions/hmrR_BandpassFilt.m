% SYNTAX:
% data2 = hmrR_BandpassFilt(data, hpf, lpf)
%
% UI NAME:
% Bandpass_Filter
%
% DESCRIPTION:
% Perform a bandpass filter on time course data.
%
% INPUT:
% data - SNIRF data type containing data time course to filter, time vector, and channels.
% hpf - high pass filter frequency (Hz)
%       Typical value is 0 to 0.02.
% lpf - low pass filter frequency (Hz)
%       Typical value is 0.5 to 3.
%
% OUTPUT:
% data2 - SNIRF data type containing the filtered data time course data
%
% USAGE OPTIONS:
% Bandpass_Filter_OpticalDensity: dod = hmrR_BandpassFilt(dod, hpf, lpf)
% Bandpass_Filter_Auxiliary: aux = hmrR_BandpassFilt(aux, hpf, lpf)
%
% PARAMETERS:
% hpf: [0.010]
% lpf: [0.500]

function [data2, ylpf] = hmrR_BandpassFilt( data, hpf, lpf )
if isa(data, 'DataClass')
    data2 = DataClass().empty();
elseif isa(data, 'AuxClass')
    data2 = AuxClass().empty();
end
ylpf = [];
for ii=1:length(data)
    if isa(data, 'DataClass')
        data2(ii) = DataClass(data(ii));
    elseif isa(data, 'AuxClass')
        data2(ii) = AuxClass(data(ii));
    end
    y = data2(ii).GetDataTimeSeries();
    fs = data2(ii).GetTime();
    
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
    ylpf = filtfilt(fb,fa,double(y));
    
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
    data2(ii).SetDataTimeSeries(y2);
    
end

