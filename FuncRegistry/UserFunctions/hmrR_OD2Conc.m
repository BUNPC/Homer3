% SYNTAX:
% dc = hmrR_OD2Conc( dod, probe, ppf )
%
% UI NAME:
% OD_to_Conc
%
% DESCRIPTION:
% Convert OD to concentrations.
%
% INPUTS:
% dod: SNIRF.data container with the Change in OD tim course 
% probe: SNIRF.probe container with the source/detector geometry
% ppf: Partial path length factors for each wavelength. This is a vector of  
%      factors per wavelength.  Typical value is ~6 for each 
%      wavelength if the absorption change is uniform over the volume of tissue measured. 
%      To approximate the partial volume effect of a small localized absorption change 
%      within an adult human head, this value could be as small as 0.1. Convention is 
%      becoming to set ppf=1 and to not divide by the source-detector separation such that 
%      the resultant "concentration" is in units of Molar mm (or Molar cm if those are the 
%      spatial units). This is becoming wide spread in the literature but there is no 
%      fixed citation. Use a value of 1 to choose this option.
%
% OUTPUTS:
% dc: SNIRF.data container with the concentration data 
%
% USAGE OPTIONS:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc( dod, probe, ppf )
%
% PARAMETERS:
% ppf: [1.0, 1.0]
%
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )
function dc = hmrR_OD2Conc( dod, probe, ppf )

dc = DataClass().empty();

for ii=1:length(dod)
    dc(ii) = DataClass();
    
    Lambda = probe.GetWls();
    SrcPos = probe.GetSrcPos();
    DetPos = probe.GetDetPos();
    nWav   = length(Lambda);
    ml     = dod(ii).GetMeasList();
    y      = dod(ii).GetDataTimeSeries();
    
    if length(ppf) < nWav
        warning('Length of ppf does not match the number of wavelengths. Falling back to ppf=1 for all wavelengths.');
        ppf = ones(1, nWav);
    elseif length(ppf) > nWav
        d = length(ppf)-nWav;
        ppf(end-d+1:end) = [];
    end
    
    if ~isempty(find(ppf==1))
        ppf = ones(size(ppf));
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
        if ppf(1)~=1
            y2(:,k:k+1) = ( einv * (y(:,[idx1 idx2'])./(ones(nTpts,1)*rho*ppf))' )';
        else
            y2(:,k:k+1) = ( einv * (y(:,[idx1 idx2'])./(ones(nTpts,1)))' )';
        end
        y2(:,k+2) = y2(:,k) + y2(:,k+1);
        dc(ii).AddChannelHbO(ml(idx1,1), ml(idx1,2));
        dc(ii).AddChannelHbR(ml(idx1,1), ml(idx1,2));
        dc(ii).AddChannelHbT(ml(idx1,1), ml(idx1,2));
    end   
    dc(ii).SetDataTimeSeries(y2);
    dc(ii).SetTime(dod(ii).GetTime());
end

