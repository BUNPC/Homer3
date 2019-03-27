function p = timeExcludeRanges(tInc,t)

p=[];
mdiff = diff(tInc);
tidx1 = find(mdiff==-1);
tidx2 = find(mdiff==1);

% If excluded time points are at the extremes of the time range, 
% then add inflections at the beginning or end.
if tInc(1)==0
    tidx1 = [1;tidx1];
end
if tInc(end)==0
    tidx2 = [tidx2;length(tInc)];
end
% if ~isempty(tidx2) && isempty(find(tidx1<tidx2(1)))
%     tidx1 = [1; tidx1];
% end
% if ~isempty(tidx1) && isempty(find(tidx2>tidx1(end)))
%     tidx2 = [tidx2; length(tInc)];
% end

for ii=1:length(tidx1)
    if ii<=length(tidx2)
        p(ii,:) = [t(tidx1(ii)) t(tidx2(ii))];
    else
        p(ii,:) = [t(tidx1(ii)) t(end)];
    end
end
