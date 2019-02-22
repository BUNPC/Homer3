% SYNTAX:
% dod = hmrR_Intensity2OD_Nirs( d )
%
% UI NAME:
% Intensity_to_Delta_OD 
%
% DESCRIPTION:
% Converts internsity (raw data) to optical density
%
% INPUT:
% d - intensity data (#time points x #data channels
%
% OUTPUT:
% dod - the change in optical density
%
% USAGE OPTIONS:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD_Nirs(d)
%
function dod = hmrR_Intensity2OD_Nirs( d )

% convert to dod
dm = mean(abs(d),1);
nTpts = size(d,1);
dod = -log(abs(d)./(ones(nTpts,1)*dm));

%if ~isempty(find(d(:)<0, 1))
%    warning( 'WARNING: Some data points in d are negative.' );
%end
