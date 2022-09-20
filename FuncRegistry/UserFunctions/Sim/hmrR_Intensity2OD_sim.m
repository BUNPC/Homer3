% SYNTAX:
% dod = hmrR_Intensity2OD_sim( intensity )
%
% UI NAME:
% Intensity_to_Delta_OD
%
% DESCRIPTION:
% Converts intensity data to optical density
%
% INPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% OUTPUT:
% dod - SNIRF data type where the d matrix is change in optical density
%
% USAGE OPTIONS:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD_sim(data)
%
function dod = hmrR_Intensity2OD_sim( intensity )

% convert to dod
dod = DataClass().empty();
for ii=1:length(intensity)
    dod(ii) = DataClass();
    d = intensity(ii).GetDataTimeSeries();
    dod(ii).SetTime(intensity(ii).GetTime());
    dod(ii).SetDataTimeSeries(d);
    dod(ii).SetMl(intensity(ii).GetMl());
    dod(ii).SetDataTypeDod();
end
