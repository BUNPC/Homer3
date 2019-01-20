% dod = hmrIntensity2OD( d )
%
% UI NAME:
% Intensity_to_OD 
%
% Converts internsity (raw data) to optical density
%
% INPUT
% d - intensity data (#time points x #data channels
%
% OUTPUT
% dod - the change in optical density

function dod = hmrIntensity2OD( d )

% convert to dod
dm = mean(abs(d),1);
nTpts = size(d,1);
dod = -log(abs(d)./(ones(nTpts,1)*dm));

%if ~isempty(find(d(:)<0, 1))
%    warning( 'WARNING: Some data points in d are negative.' );
%end
