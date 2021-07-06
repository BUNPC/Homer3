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
%       Typical value is 0 to 0.01.
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
% hpf: [0.000]
% lpf: [0.500]
%
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )

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
    y2 = y;
    fs = data2(ii).GetTime();
    
    % convert t to fs
    % assume fs is a time vector if length>1
    if length(fs)>1
        fs = 1/(fs(2)-fs(1));
    end
    
    % Check for NaN
    if max(max(isnan(y)))
       warning('Input to hmrR_BandpassFilt contains NaN values. Add hmrR_PreprocessIntensity_NAN to the processing stream.');
       return
    end
    % Check for finite values
    if max(max(isinf(y)))
       warning('Input to hmrR_BandpassFilt must be finite.');
       return
    end

    % Check that cutoff < nyquist
    if lpf / (fs / 2) > 1 || hpf / (fs / 2) > 1
        warning(['hmrR_BandpassFilt cutoff cannot exceed the folding frequency of the data with sample rate ', num2str(fs), ' hz.']);
        return
    end
    
    % low pass filter
    lpf_norm = lpf / (fs / 2);
    if lpf_norm > 0  % No lowpass if filter is 
        FilterOrder = 3;
        [z, p, k] = butter(FilterOrder, lpf_norm, 'low');
        [sos, g] = zp2sos(z, p, k);
        y2 = filtfilt(sos, g, double(y)); 
    end
    
    % high pass filter
    hpf_norm = hpf / (fs / 2);
    if hpf_norm > 0
        FilterOrder = 5;
        [z, p, k] = butter(FilterOrder, hpf_norm, 'high');
        [sos, g] = zp2sos(z, p, k);
        y2 = filtfilt(sos, g, y2);
    end
    
    data2(ii).SetDataTimeSeries(y2);
    
end
