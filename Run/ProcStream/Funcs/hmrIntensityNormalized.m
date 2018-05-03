% dod = hmrIntensityNormalized( d )
%
% UI NAME
% Intensity_Normalized
%
%
% INPUT
% d - intensity data (#time points x #data channels)
%
% OUTPUT
% dod - the intensity divided by the mean

function dod = hmrIntensityNormalized( d )

% normalize
dm = mean(abs(d),1);
nTpts = size(d,1);
dod = abs(d)./(ones(nTpts,1)*dm);

