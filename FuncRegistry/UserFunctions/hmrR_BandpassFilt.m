% SYNTAX:
% [data2, Aux2] = hmrR_BandpassFilt(data, Aux, hpf, lpf, turnon_dod, turnon_aux )
%
% UI NAME:
% Bandpass_Filter
%
% DESCRIPTION:
% Perform a bandpass filter on time course data.
%
% INPUT:
% data - SNIRF data type containing data time course to filter, time
%       vector, and channels.
% Aux - auxilliary data
% hpf - high pass filter frequency (Hz)
%       Typical value is 0 to 0.02.
% lpf - low pass filter frequency (Hz)
%       Typical value is 0.5 to 3.
% turnon_dod - apply filter on dod when set to 1
% turnon_aux - apply filter on aux when set to 1
%
% OUTPUT:
% data2 - SNIRF data type containing the filtered data time course, time
%        vector, and channels.
% Aux2 - filtered aux
%
% USAGE OPTIONS:
% Bandpass_Filter: [dod, Aux2] = hmrR_BandpassFilt(dod, Aux, hpf, lpf, turnon_dod, turnon_aux )
%
% PARAMETERS:
% hpf: [0.010]
% lpf: [0.500]
% turnon_dod: 1
% turnon_aux: 1

function [data2, Aux2] = hmrR_BandpassFilt(data, Aux, hpf, lpf, turnon_dod, turnon_aux)

if turnon_dod && turnon_aux
    foo{1} = data;
    foo{2} = Aux;
    data2 = DataClass().empty();
    Aux2 = AuxClass().empty();
elseif turnon_dod
    foo{1} = data;
    data2 = DataClass().empty();
    Aux2 = Aux;
elseif turnon_aux
    foo{1} = Aux;
    Aux2 = AuxClass().empty();
    data2 = data;
else
    data2 = data;
    Aux2 = Aux;
    return
end

for i = 1:size(foo,2)
    ylpf = [];
    for ii=1:length(foo{i})
        if isa(foo{i}, 'DataClass')
            data2(ii) = DataClass(foo{i}(ii));
            y = data2(ii).GetDataTimeSeries();
            fs = data2(ii).GetTime();
        elseif isa(foo{i}, 'AuxClass')
            Aux2(ii) = AuxClass(foo{i}(ii));
            y = Aux2(ii).GetDataTimeSeries();
            fs = Aux2(ii).GetTime();
        end
        
        
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
        
        if isa(foo{i}, 'DataClass')
            data2(ii).SetDataTimeSeries(y2);
        elseif isa(foo{i}, 'AuxClass')
            Aux2(ii).SetDataTimeSeries(y2);
        end
        
    end
    
end