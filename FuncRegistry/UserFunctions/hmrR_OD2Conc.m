% SYNTAX:
% dc = hmrR_OD2Conc( dod, sd, ppf )
%
% UI NAME:
% OD_to_Conc
%
% DESCRIPTION:
% Convert OD to concentrations
%
% INPUTS:
% dod: SNIRF.data container with the Change in OD tim course 
% sd:  SNIRF.sd container with the source/detector geometry
% ppf: Partial pathlength factors for each wavelength. If there are 2
%      wavelengths of data, then this is a vector ot 2 elements.
%      Typical value is ~6 for each wavelength if the absorption change is 
%      uniform over the volume of tissue measured. To approximate the
%      partial volume effect of a small localized absorption change within
%      an adult human head, this value could be as small as 0.1.
%
% OUTPUTS:
% dc: SNIRF.data container with the concentration data 
%
% USAGE OPTIONS:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc( dod, sd, ppf )
%
% PARAMETERS:
% ppf: [6.0, 6.0]
%
function dc = hmrR_OD2Conc( dod, sd, ppf )

for ii=1:length(dod)
    dc(ii) = DataClass();
    
    Lambda = sd.GetWls();
    SrcPos = sd.GetSrcPos();
    DetPos = sd.GetDetPos();
    nWav   = length(Lambda);
    ml     = dod(ii).GetMeasList();
    y      = dod(ii).GetD();
    
    if length(ppf)~=nWav
        errordlg('The length of PPF must match the number of wavelengths in SD.Lambda');
        dc = zeros(size(y,1),3,length(find(ml(:,4)==1)));
        return
    end
    
    nTpts = size(y,1);
    
    e = GetExtinctions(Lambda);
    e = e(:,1:2) / 10; % convert from /cm to /mm
    einv = inv( e'*e )*e';
    
    lst = find( ml(:,4)==1 );
    y2 = zeros(nTpts, 3*length(lst));
    for idx=1:length(lst)
        k = 3*(idx-1)+1;
        idx1 = lst(idx);
        idx2 = find( ml(:,4)>1 & ml(:,1)==ml(idx1,1) & ml(:,2)==ml(idx1,2) );
        rho = norm(SrcPos(ml(idx1,1),:)-DetPos(ml(idx1,2),:));
        y2(:,k:k+1) = ( einv * (y(:,[idx1 idx2'])./(ones(nTpts,1)*rho*ppf))' )';
        y2(:,k+2) = y2(:,k) + y2(:,k+1);
        dc(ii).AddChannelDc(ml(idx1,1), ml(idx1,2), 6);
        dc(ii).AddChannelDc(ml(idx1,1), ml(idx1,2), 7);
        dc(ii).AddChannelDc(ml(idx1,1), ml(idx1,2), 8);
    end   
    dc(ii).SetD(y2);
    dc(ii).SetT(dod(ii).GetT());
end

