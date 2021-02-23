% SYNTAX:
% data2 = hmrR_PreprocessOD_LinearFit(data, turnon)
%
% UI NAME:
% LinearFit
%
% DESCRIPTION:
% Perform a linear fit and removes it from the time course data.
%
% INPUT:
% data - SNIRF data type containing data time course to filter, time vector, and channels.
% turnon - 1 turns the function on
%
% OUTPUT:
% data2 - SNIRF data type containing the filtered data time course data
%
% USAGE OPTIONS:
% Linear_Fit_OpticalDensity: dod = hmrR_PreprocessOD_LinearFit(dod, turnon)
%
% PARAMETERS:
% turnon: [1]

function [data2] = hmrR_PreprocessOD_LinearFit( data, turnon )

if turnon == 1
    
    if isa(data, 'DataClass')
        data2 = DataClass().empty();
    end
    
    
    for ii=1:length(data)
        
        if isa(data, 'DataClass')
            data2(ii) = DataClass(data(ii));
        end
        X = data2(ii).GetDataTimeSeries();
        t = data2(ii).GetTime();
        
        
        for j = 1:size(X,2) % channel
            p = polyfit(t,X(:,j),1);
            yfit = polyval(p,t);
            X_yfit(:,j) = X(:,j)-yfit;
        end
        
    end
    
    data2(ii).SetDataTimeSeries(X_yfit);
else
    data2 = data;
end
