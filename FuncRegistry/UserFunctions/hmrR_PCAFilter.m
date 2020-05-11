% SYNTAX:
% [data_yc, svs, nSV] = hmrR_PCAFilter( data_y, mlAct, tInc, nSV )
%
% UI NAME:
% PCA_Filter
%
% DESCRIPTION:
% Perform a PCA filter on the data matrix y. 
%
% INPUT:
% data_y: SNIRF object containing data matrix where rows are time points. If y is wavelength
%    data, then the columns are channels as described in ml. If
%    y is concentration data, then the third dimension is channels and the
%    second dimension indicates HbO and HbR.
% mlAct: 
% tInc: This is a vector of length number of time points and is 1 to
%    indicate that a time point is included in the analysis and 0 if it is to
%    be excluded. This is useful for ignoring periods of time with strong
%    artifacts.
% nSV: This is the number of principle components to remove filter from the
%    data. This can be an integer to indicate the number of components to
%    remove. Or it can be a fraction less than 1 to indicate that enough
%    components should be removed to remove up to that fraction of the
%    variance in the data. If nSV is a single number it is applied to all
%    channels of data. This is useful for filtering motion artifacts. If it is
%    2 or more numbers, then it is applied to each wavelength or concentration
%    separately using the corresponding number.
%
%
% OUTPUT:
% data_yc: SNIRF object containing the filtered data matrix.
% svs: Cell array for each data block with the singuler value spectrum from the PCA.
% nSV: Cell array for each data block with the number of components filtered from the data.
%
% USAGE OPTIONS:
% PCA_Filter_Delta_OD:           [dod, svs, nSV] = hmrR_PCAFilter( dod, mlActAuto, tIncAuto, nSV )
% PCA_Filter_Concentration_Data: [dc, svs, nSV]  = hmrR_PCAFilter( dc, mlActAuto, tIncAuto, nSV )
%
% PARAMETERS:
% nSV: 0.00
%
function [data_yc, svs, nSV] = hmrR_PCAFilter( data_y, mlAct, tInc, nSV )

data_yc = DataClass().empty();
svs     = cell(length(data_y),1);
nSV     = repmat({nSV}, length(data_y),1);

% Error check arguments
% Check input args
if isempty(tInc)
    tInc = cell(length(data_y),1);
end
if isempty(mlAct)
    mlAct = cell(length(data_y),1);
end
if ~exist('nSV','var')
    disp('USAGE: [yc,svs,nSV] = hmrR_PCAFilter( y, SD, tInc, nSV )');
    return
end

for iBlk=1:length(data_y)
    
    % Initialize the main output data with the input data
    data_yc(iBlk) = DataClass(data_y(iBlk));
        
    % Get all the input data from the arguments
    y        = data_y(iBlk).GetDataTimeSeries('reshape');
    t        = data_y(iBlk).GetTime();
    MeasList = data_y(iBlk).GetMeasList();
    if isempty(mlAct{iBlk})
        mlAct{iBlk} = ones(size(MeasList,1),1);
    end
    MeasListAct = mlAct{iBlk};
    if isempty(tInc{iBlk})
        tInc{iBlk} = ones(length(t),1);
    end
    tInc = tInc{iBlk};
    
    lstInc   = find(tInc==1);    
    ml       = MeasList;

    % Error check for the input data
    if any(isinf(y(:)))
        disp('WARNING: [yc,svs,nSV] = hmrR_PCAFilter( y, SD, tInc, nSV )');
        disp('      The data matrix y can not have any Inf numbers.');
        continue
    end
    
    % do the PCA
    ndim = ndims(y);    
    if ndim==3
        
        % PCA on Concentration
        lstAct = find(MeasListAct==1);
        lstAct = lstAct( find(ml(lstAct,4)==1) );
        yo = y(lstInc,:,lstAct);
        yc = y;
        for iConc = 1:2
            y = squeeze(yo(:,iConc,:));
            y=detrend(y);
            c = y.' * y;
            [v,s,foo] = svd(c);
            u = y*v*inv(s);
            svs{iBlk}(:,iConc) = diag(s)/sum(diag(s));
            if nSV{iBlk}(iConc)<1 % find number of SV to get variance up to nSV
                svsc = svs{iBlk}(:,iConc);
                for idx = 2:size(svs{iBlk},1)
                    svsc(idx) = svsc(idx-1) + svs{iBlk}(idx,iConc);
                end
                ev = diag(svsc<nSV{iBlk}(iConc));
                nSV{iBlk}(iConc) = find(diag(ev)==0,1)-1;
            else
                ev = zeros(size(svs{iBlk},1),1);
                ev(1:nSV{iBlk}(iConc)) = 1;
                ev = diag(ev);
            end
            lst = 1:nSV{iBlk}(iConc);
            yc(lstInc,iConc,lstAct) = y - u(:,lst)*s(lst,lst)*v(:,lst)';
        end
        yc(:,3,:) = yc(:,1,:) + yc(:,2,:);
        
    else
        
        % PCA on wavelength data        
        if length(nSV{iBlk})==1
            % apply PCA to all data
            lstAct = find(MeasListAct==1);
            yc = y;
            yo = y(lstInc,lstAct);
            y = squeeze(yo);
            
            c = y.' * y;
            [V,St,foo] = svd(c);
            svs{iBlk} = diag(St) / sum(diag(St));
            %        [foo,St,V] = svd(y);
            %        svs{iBlk} = diag(St).^2/sum(diag(St).^2);
            %        figure; plot(svsc,'*-');
            if nSV{iBlk}<1 % find number of SV to get variance up to nSV{iBlk}
                svsc = svs{iBlk};
                for idx = 2:size(svs{iBlk},1)
                    svsc(idx) = svsc(idx-1) + svs{iBlk}(idx);
                end
                ev = diag(svsc<nSV{iBlk});
                nSV{iBlk} = find(diag(ev)==0,1)-1;
            else
                ev = zeros(size(svs{iBlk},1),1);
                ev(1:nSV{iBlk}) = 1;
                ev = diag(ev);
            end
            yc(lstInc,lstAct) = yo - y*V*ev*V';
            
        elseif length(nSV{iBlk})==2
            % apply to each wavelength individually
            % verify that length(nSV{iBlk})==length(wavelengths)
            yc = y;
            for iW=1:2
                lstAct = find(MeasListAct==1 & MeasList(:,4)==iW);
                yo = y(lstInc,lstAct);
                yo = squeeze(yo);
                
                c = yo.' * yo;
                [V,St,foo] = svd(c);
                svs{iBlk}(:,iW) = diag(St) / sum(diag(St));
                %        [foo,St,V] = svd(y);
                %        svs{iBlk} = diag(St).^2/sum(diag(St).^2);
                %        figure; plot(svsc,'*-');
                if nSV{iBlk}(iW)<1 % find number of SV to get variance up to nSV{iBlk}
                    svsc = svs{iBlk}(:,iW);
                    for idx = 2:size(svs{iBlk},1)
                        svsc(idx) = svsc(idx-1) + svs{iBlk}(idx,iW);
                    end
                    ev = diag(svsc<nSV{iBlk}(iW));
                    nSV{iBlk}(iW) = find(diag(ev)==0,1)-1;
                else
                    ev = zeros(size(svs{iBlk},1),1);
                    ev(1:nSV{iBlk}(iW)) = 1;
                    ev = diag(ev);
                end
                yc(lstInc,lstAct) = yo - yo*V*ev*V';
            end
            
        else
            warndlg( 'hmrR_PCAFilter was not passed proper arguments', 'hmrPCAFilter' )
        end
    end
    
    if isempty(nSV{iBlk})
        nSV{iBlk} = 0;
    end
    
    data_yc(iBlk).SetDataTimeSeries(yc);
    
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
end

