% SYNTAX:
% [data_d, svs, nSV] = hmrR_MotionCorrectPCA(data_d, mlActMan, tIncMan, nSV)
%
% UI NAME:
% Motion_Correct_PCA
%
% This function uses PCA to filter only the segments of data identified as
% a motion artifact. The motion artifacts are indicated in the tInc vector
% by the value of 0.
%
%
% INPUTS
% data_d:  SNIRF object containing data matrix, timepoints x sd pairs
% mlActMan: Active data channels are indicated mlActMan.
% tIncMan: Cell array for eqach data block with vectors of length time points
%          where 1's indicating data included and 0's indicating motion artifact
% nSV: Cell array for each data block with the number of principal components to remove
%      from each data block. If this number is less than 1, then the filter removes the first n
%      components of the data that removes a fraction of the variance up to nSV. Percent variance 
%      you want to remove, or give an integer for number ofcomponents to remove
%
%
% OUTPUTS
% data_dN: SNIRF object containing the motion corrected data matrix.
% svs: Cell array for each data block with the singular values of the PCA
% nSV: Cell array for each data block with the number of singular values removed from the data.
%
%
% USAGE OPTIONS:
% Motion_Correct_PCA:  [dod, svs, nSV] = hmrR_MotionCorrectPCA(dod, mlActMan, tIncMan, nSV)
%
% PARAMETERS:
% nSV: 0.0
%
function [data_dN, svs, nSV] = hmrR_MotionCorrectPCA(data_d,  mlActMan, tIncMan, nSV)

% Init output 
data_dN = DataClass.empty();
svs = cell(length(data_d),1);
if ~iscell(nSV)
    nSV = repmat({nSV}, length(data_d),1);
end

% Check input args
if isempty(tIncMan)
    tIncMan = cell(length(data_d),1);
end
if isempty(mlActMan)
    mlActMan = cell(length(data_d),1);
end

for iBlk=1:length(data_d)
    data_dN(iBlk) = DataClass(data_d(iBlk));

    d           = data_d(iBlk).GetDataTimeSeries();
    MeasList    = data_d(iBlk).GetMeasList();
    if isempty(mlActMan{iBlk})
        mlActMan{iBlk} = ones(size(MeasList,1),1);
    end
    mlAct = mlActMan{iBlk};
    if isempty(tIncMan{iBlk})
        tIncMan{iBlk} = ones(size(d,1),1);
    end
    tInc = tIncMan{iBlk};
    
    lstNoInc = find(tInc==0);
    lstAct = find(mlAct==1);
    
    if isempty(lstNoInc)
        nSV{iBlk} = 0;
        continue;
    end
    
    %
    % Do PCA
    %
    y = d(lstNoInc,lstAct);
    yo = y;
    
    c = y.' * y;
    [V,St,foo] = svd(c);
    svs{iBlk} = diag(St) / sum(diag(St));
    
    svsc = svs{iBlk};
    for idx = 2:size(svs{iBlk},1)
        svsc(idx) = svsc(idx-1) + svs{iBlk}(idx);
    end
    if nSV{iBlk}<1 & nSV{iBlk}>0 % find number of SV to get variance up to nSV{iBlk}
        ev = diag(svsc<nSV{iBlk});
        nSV{iBlk} = find(diag(ev)==0,1)-1;
    end
    
    ev = zeros(size(svs{iBlk},1),1);
    ev(1:nSV{iBlk}) = 1;
    ev = diag(ev);
    
    yc = yo - y*V*ev*V';
    
    %
    % splice the segments of data together
    %
    lstMs = find(diff(tInc)==-1);
    lstMf = find(diff(tInc)==1);
    if isempty(lstMf)
        lstMf = length(tInc);
    end
    if isempty(lstMs)
        lstMs = 1;
    end
    if lstMs(1)>lstMf(1)
        lstMs = [1;lstMs];
    end
    if lstMs(end)>lstMf(end)
        lstMf(end+1,1) = length(tInc);
    end
    lstMb = lstMf-lstMs;
    for ii=2:length(lstMb)
        lstMb(ii) = lstMb(ii-1) + lstMb(ii);
    end
    
    dN = d;
    
    for ii=1:length(lstAct)
        jj = lstAct(ii);
        
        lst = (lstMs(1)):(lstMf(1)-1);
        if lstMs(1)>1
            dN(lst,jj) = yc(1:lstMb(1),ii) - yc(1,ii) + dN(lst(1),jj);
        else
            dN(lst,jj) = yc(1:lstMb(1),ii) - yc(lstMb(1),ii) + dN(lst(end),jj);
        end
        
        for kk=1:(length(lstMf)-1)
            lst = (lstMf(kk)-1):lstMs(kk+1);
            dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);
            
            lst = (lstMs(kk+1)):(lstMf(kk+1)-1);
            dN(lst,jj) = yc((lstMb(kk)+1):lstMb(kk+1),ii) - yc(lstMb(kk)+1,ii) + dN(lst(1),jj);
        end
        
        if lstMf(end)<length(d)
            lst = (lstMf(end)-1):length(d);
            dN(lst,jj) = d(lst,jj) - d(lst(1),jj) + dN(lst(1),jj);
        end
    end
    
    data_dN(iBlk).SetDataTimeSeries(dN);
end

