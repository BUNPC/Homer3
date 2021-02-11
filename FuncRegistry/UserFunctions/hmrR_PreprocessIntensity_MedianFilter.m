% SYNTAX:
% intensity = hmrR_PreprocessIntensity_MedianFilter( intensity )
%
% UI NAME:
% hmrR_PreprocessIntensity_MedianFilter
%
% DESCRIPTION:
% Applies a median filter to data to remove huge spikes.
%
% INPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% OUTPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% USAGE OPTIONS:
% Intensity_to_Intensity: d = hmrR_PreprocessIntensity_MedianFilter(data)


function d = hmrR_PreprocessIntensity_MedianFilter( intensity)


for ii=1:length(intensity)
    d = intensity(ii).GetDataTimeSeries();
    
    for j = 1:size(d,2)
        foo = d(:,j);
        
        
        xdata = (1:length( foo))';
        d(:,j) = interp1(xdata(~isnan( foo)), foo(~isnan( foo)),xdata,'spline');
        
        new_signal = zeros(size(foo));
        new_signal(1) = foo(1);
        new_signal(end) = foo(end);
        for tp = 2:length(foo)-1
            values = foo([tp-1,tp,tp+1]);
            median_value = median(values);
            new_signal(tp) = median_value;
        end
        d(:,j) = new_signal;
        
    end
    
    intensity(ii).SetDataTimeSeries(d);
end
