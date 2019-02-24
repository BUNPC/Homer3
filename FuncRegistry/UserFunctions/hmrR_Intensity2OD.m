% SYNTAX:
% dod = hmrR_Intensity2OD( intensity )
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
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD(data)
%
function dod = hmrR_Intensity2OD( intensity )

% intensity is a handle object, make sure we don't change 
% it by working only with a copy. 
dod = intensity.copydeep();

% convert to dod
for ii=1:length(intensity)
    d = dod(ii).GetD();
    dm = mean(abs(d),1);
    nTpts = size(d,1);
    dod(ii).SetD(-log(abs(d)./(ones(nTpts,1)*dm)));
    dod(ii).SetDataType(1000, 1);
end
