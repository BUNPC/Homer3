function [mlAll, k] = sort_ml(ml)

mlAll = ml;
if size(ml,2)==2
    len = size(ml,1);
    nWls = 1;
elseif size(ml,2)==4
    k = find(ml(:,4)==1);
    len = length(k);
    nWls = length(unique(ml(:,4)));    
end
[ml,k] = sort_ml_wavelength(ml(k,1:2));

for ii=1:nWls
    iStart = (ii-1)*len+1;
    iEnd   = iStart+len-1;
    mlAll(iStart:iEnd,:) = [ml, ones(len,1), ii*ones(len,1)];
end


% ----------------------------------------------------------
function [ml,k] = sort_ml_wavelength(ml)
k=[];
if(isempty(ml))
    return;
end
ml0=ml;

% Sort meas list by src (1st column)
[~,i] = sort(ml(:,1));
ml = ml(i,:);
src_idxs = unique(ml(:,1))';

% Sort meas list by src (1st column) and Det (2nd column)
for i=src_idxs
    k = find(ml(:,1)==i);
    if(~isempty(k))
        [~,j]=sort(ml(k,2));
        ml2 = ml(k,:);
        ml(k,:) = ml2(j,:);
    end
end

% Meas list is sorted. Now just set the output argument k
% which are the previous ml indices of the in the current
% list. It shows how the list was rearranged so that it is
% sorted.
for j=1:size(ml,1)
    i = find(ml(:,1)==ml0(j,1) & ml(:,2)==ml0(j,2));
    if(length(i)>1)
        error('Error: Measurement list in wrong format - some pairs not unique.');
    end
    k(j) = i;
end
