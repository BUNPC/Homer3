function b = isequal_prec(x1,x2,n)

% Usage:
% 
%    b = isequal_prec(x1,x2,n) 
%    b = isequal_prec(x1,x2)
%
% Description:
% 
%    Compare two numbers for equality based on the nth decimal place. 
%    If the 3rd argument is not supplied then x1 and x2 have to be preceisely
%    equal for the function to return true, ie, the function will return the 
%    value of x1==x2. Otherwise it works as follows:
%
%          n>0 ==> round to the nearest positive decimal place
%          n=0 ==> round to the nearest integer
%          n<0 ==> round to the nearest negative decimal place
%
% Examples: 
%     
%    
%
DEBUG=0;

b = false;

if ~exist('n','var') || isempty(n)
    n = [];
end

if ~all(size(x1) == size(x2))
    return;
end
if ~all(isnan(x1) == isnan(x2))
    return;
end
if isempty(n)
    y1 = x1;
    y2 = x2;
else
    y1 = round(x1,-n);
    y2 = round(x2,-n);
end

% We use isequaln instead of == because it handles NaN gracefully, 
% whereas == operator does not (gives wrong answer when both sides 
% are NaN). 
if isequaln(y1,y2)
    b = true;
elseif all(abs(x1-x2)<(10^n))
    b = true;
end

if DEBUG
    flag = 0;
    for ii=1:length(y1(:))
        if ~isequaln(y1(ii),y2(ii))
            flag = 1;
            eval( sprintf( 'fprintf(''%%d: %%0.%df == %%0.%df is FALSE\\n'', ii, y1(ii), y2(ii));', abs(n), abs(n) ) );
        end
    end
    if flag
        fprintf('\n');
    end
end

