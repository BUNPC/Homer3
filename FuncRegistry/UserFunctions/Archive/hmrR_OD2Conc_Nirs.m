% SYNTAX:
% dc = hmrR_OD2Conc_Nirs( dod, SD, ppf )
%
% UI NAME:
% OD_to_Conc
%
% DESCRIPTION:
% Convert OD to concentrations
%
% INPUTS:
% dod: the change in OD (#time points x #channels)
% SD:  the SD structure
% ppf: Partial path length factors for each wavelength. If there are 2 wavelengths 
%      of data, then this is a vector of 2 elements.  Typical value is ~6 for each 
%      wavelength if the absorption change is uniform over the volume of tissue measured. 
%      To approximate the partial volume effect of a small localized absorption change 
%      within an adult human head, this value could be as small as 0.1. It is recommended 
%      to use default values of “1 1” which will result in concentration units of 
%      “molar ppf” such that the user can then divide by an estimated ppf at any future 
%      point to estimate what the molar concentration change would be.%
%
% OUTPUTS:
% dc: the concentration data (#time points x 3 x #SD pairs
%     3 concentrations are returned (HbO, HbR, HbT)
%
% USAGE OPTIONS:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc_Nirs( dod, SD, ppf )
%
% PARAMETERS:
% ppf: [1.0, 1.0]
%
function dc = hmrR_OD2Conc_Nirs( dod, SD, ppf )

nWav = length(SD.Lambda);
ml = SD.MeasList;

if length(ppf)~=nWav
    errordlg('The length of PPF must match the number of wavelengths in SD.Lambda');
    dc = zeros(size(dod,1),3,length(find(ml(:,4)==1)));
    return
end

nTpts = size(dod,1);

e = GetExtinctions( SD.Lambda );
e = e(:,1:2) / 10; % convert from /cm to /mm
einv = inv( e'*e )*e';

lst = find( ml(:,4)==1 );
for idx=1:length(lst)
    idx1 = lst(idx);
    idx2 = find( ml(:,4)>1 & ml(:,1)==ml(idx1,1) & ml(:,2)==ml(idx1,2) );
    rho = norm(SD.SrcPos(ml(idx1,1),:)-SD.DetPos(ml(idx1,2),:));
    dc(:,:,idx) = ( einv * (dod(:,[idx1 idx2'])./(ones(nTpts,1)*rho*ppf))' )';
end
dc(:,3,:) = dc(:,1,:) + dc(:,2,:);
