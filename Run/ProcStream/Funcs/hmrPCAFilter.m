% TO DO
% working on Conc, all data, or wavelengths
% check nSV
function [yc, svs, nSV] = hmrPCAFilter( y, SD, nSV )

if ~exist('nSV')
    disp('USAGE: [yc,svs] = hmrPCAFilter( y, SD, nSV )');
    return
end

ml = SD.MeasList;
nMeas = size(ml,1);
nLambda = length(SD.Lambda);
for ii=1:nLambda
    nMeasPerLambda(ii) = length(find(ml(:,4)==ii));
end

if ~isfield(SD,'MeasListAct')
    SD.MeasListAct = ones(nMeas,1);
end

% do the PCA
ndim = ndims(y);

if ndim==3
    % PCA on Concentration
    lstAct = find(SD.MeasListAct==1);
    lstAct = lstAct( find(ml(lstAct,4)==1) );
    yo = y(:,:,lstAct);
    yc = y;
    for iConc = 1:2
        y = squeeze(yo(:,iConc,:));
        y=detrend(y);
        c = y.' * y;
        [v,s,foo] = svd(c);
        u = y*v*inv(s);
        svs(:,iConc) = diag(s)/sum(diag(s));
        if nSV(iConc)<1 % find number of SV to get variance up to nSV
            svsc = svs(:,iConc);
            for idx = 2:size(svs,1)
                svsc(idx) = svsc(idx-1) + svs(idx,iConc);
            end
            ev = diag(svsc<nSV(iConc));
            nSV(iConc) = find(diag(ev)==0,1)-1;
        else
            ev = zeros(size(svs,1),1);
            ev(1:nSV(iConc)) = 1;
            ev = diag(ev);
        end
        lst = 1:nSV(iConc);
        yc(:,iConc,lstAct) = y - u(:,lst)*s(lst,lst)*v(:,lst)';
    end
    yc(:,3,:) = yc(:,1,:) + yc(:,2,:);
    
else
    % PCA on wavelength data
    
    if length(nSV)==1
        % apply PCA to all data
        lstAct = find(SD.MeasListAct==1);
        yc = y;
        yo = y(:,lstAct);
        y = squeeze(yo);

        c = y.' * y;
        [V,St,foo] = svd(c);
        svs = diag(St) / sum(diag(St));
%        [foo,St,V] = svd(y);
%        svs = diag(St).^2/sum(diag(St).^2);        
%        figure; plot(svsc,'*-');
        if nSV<1 % find number of SV to get variance up to nSV
            svsc = svs;
            for idx = 2:size(svs,1)
                svsc(idx) = svsc(idx-1) + svs(idx);
            end        
            ev = diag(svsc<nSV);
            nSV = find(diag(ev)==0,1)-1;
        else
            ev = zeros(size(svs,1),1);
            ev(1:nSV) = 1;
            ev = diag(ev);
        end        
        yc(:,lstAct) = yo - y*V*ev*V';

    elseif length(nSV)==2
        % apply to each wavelength individually
        % verify that length(nSV)==length(wavelengths)
        yc = y;
        for iW=1:2
            lstAct = find(SD.MeasListAct==1 & SD.MeasList(:,4)==iW);
            yo = y(:,lstAct);
            yo = squeeze(yo);
            
            c = yo.' * yo;
            [V,St,foo] = svd(c);
            svs(:,iW) = diag(St) / sum(diag(St));
            %        [foo,St,V] = svd(y);
            %        svs = diag(St).^2/sum(diag(St).^2);
            %        figure; plot(svsc,'*-');
            if nSV(iW)<1 % find number of SV to get variance up to nSV
                svsc = svs(:,iW);
                for idx = 2:size(svs,1)
                    svsc(idx) = svsc(idx-1) + svs(idx,iW);
                end
                ev = diag(svsc<nSV(iW));
                nSV(iW) = find(diag(ev)==0,1)-1;
            else
                ev = zeros(size(svs,1),1);
                ev(1:nSV(iW)) = 1;
                ev = diag(ev);
            end
            yc(:,lstAct) = yo - yo*V*ev*V';
        end

    else
        warndlg( 'hmrPCAFilter was not passed proper arguments', 'hmrPCAFilter' )
    end
end

if isempty(nSV)
    nSV = 0;
end

% use this if using s and v from baseline data
% for ii=1:size(y,3)
%     y(:,:,ii)=detrend(y(:,:,ii));
% end
% 
% lstSV= 1:nSV;
% u = y*v*inv(s);
% 
% if nSV>0
%     dd1c = dd1 - u(:,lstSV)*s(lstSV,lstSV)*v(:,lstSV)';
% else
%     dd1c = dd1;
% end
% 
