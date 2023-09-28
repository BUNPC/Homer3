function [coef, res, yhat] = ar_fit( y,Pmax,nosearch)
% y(t) = coef(1) + coef(2)*y(t-1) + coef(3)*y(t-2) ...
%
% y is a column vector with the time-series we are fitting
%
% Pmax is the max model order (not counting the constant)

if(nargin<3)
    nosearch=false;
end

n = length(y);
Pmax=max(min(Pmax,n-1),1);

Xf = lagmatrix(y, 1:Pmax);
Xb = lagmatrix(flipud(y), 1:Pmax);

X = [ones(2*n,1) [Xf; Xb]];

yy=[y; flipud(y)];
lstValid=~isnan(yy) & ~isnan(sum(X,2));

if(nosearch)
    [Q,R] = qr(X(lstValid,:),0); % note that the zero is very important for performance
    invR = pinv(R);
    coef = invR * Q'*yy(lstValid);
    res = yy(lstValid) - X(lstValid,:)*coef;
else
    [B,SE,PVAL,in,stats,nextstep,history] = stepwisefit(X(lstValid,:), yy(lstValid),'Display','off');
    coef = B;
    res = stats.yr; 
%     [coef, res] = stepwisefit(X(lstValid,:), yy(lstValid));
end
res = res(1:n);
yhat = y - res;

end