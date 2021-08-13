% SYNTAX:
% intensity = hmrR_PreprocessIntensity_NAN( intensity )
%
% UI NAME:
% hmrR_PreprocessIntensity_NAN
%
% DESCRIPTION:
% replace NAN by spline interpolation of the nonnan values
%
% INPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% OUTPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% USAGE OPTIONS:
% Intensity_to_Intensity: d = hmrR_PreprocessIntensity_NAN(data)


function d = hmrR_PreprocessIntensity_NAN( intensity)


for ii=1:length(intensity)
    d = intensity(ii).GetDataTimeSeries();
    
    if ~isempty(find(isnan(d)))
        
        for j = 1:size(d,2)
            foo = d(:,j);
            if ~isempty(find(isnan(foo))) & size(find(isnan(foo)==1),1) ~= size(d,1)
                
                xdata = (1:length( foo))';
                d(:,j) = interp1(xdata(~isnan( foo)), foo(~isnan( foo)),xdata,'spline');
                
            end
        end
        
    end
    intensity(ii).SetDataTimeSeries(d);
end
