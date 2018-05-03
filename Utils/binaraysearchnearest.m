% Binary search. 
% Search 'sval' in sorted vector 'x', returns index of 'sval' in 'x'
%  
% INPUT:
% x: vector of numeric values, x should already be sorted in ascending order
%    (e.g. 2,7,20,...120)
% sval: numeric value to be search in x
%  
% OUTPUT:
% index: index of sval with respect to x. If sval is not found in x
%        then index is empty.

% --------------------------------
% Author: Dr. Murtaza Khan
% Email : drkhanmurtaza@gmail.com
% --------------------------------

% Jay Dubb modified the above author's algorithm to find nearest 
% match instead of exact match

       
function index = binaraysearchnearest(x,sval)

index=[];
n=length(x);

if sval>=x(n)
    index=n;
    return;
end
if sval<=x(1)
    index=1;
    return;
end

from=1;
to=n;
while from<=to
    mid = round((from + to)/2);    
    diff = x(mid)-sval;
    if diff==0 || abs(to-from)<=1
        if diff==0
            index=mid;
        else
            if abs(x(from)-sval)<=abs(x(from+1)-sval)
                index=from;
            else
                index=from+1;
            end
        end
        return
    elseif diff<0   % x(mid) < sval
        from=mid+1;
    else              % x(mid) > sval
        to=mid-1;                       
    end
end

