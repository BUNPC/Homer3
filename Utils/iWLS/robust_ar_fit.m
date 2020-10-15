function [beta, P] = robust_ar_fit( y )
	warning('off','stats:statrobustfit:IterationLimit')

    yf = y;
    yb = flipud(y);
    
    bic0 = 1; bic = 0;
    P = 0; Pmax = 100;
    beta0 = []; beta = [];
    while bic0 > bic && P < Pmax
        beta0 = beta;
        bic0 = bic;
        P = P+1; 
        
        % forward design matrix
        Xf = zeros(length(yf)-P,P+1);
        Xf(:,1) = ones(length(yf)-P,1);
        for j = 1:P
            Xf(:,j+1) = yf(j+1:end-P+j);
        end

        % backward design matrix
        Xb = zeros(length(yb)-P,P+1);
        Xb(:,1) = ones(length(yb)-P,1);
        for j = 1:P
            Xb(:,j+1) = yb(j+1:end-P+j);
        end

        %  weighted least squares
        y = [yf(1:end-P); yb(1:end-P)];
        X = [Xf; Xb];

        beta = pinv(X) * y;
        r = y - X*beta;
        
        w = biweight(r);
        beta = pinv((repmat(w,[1 size(X,2)]).*X))* (w.*y);
        r = y - X*beta;

%         % robust regression
%         y = [yf(1:end-P); yb(1:end-P)];
%         X = [Xf; Xb];
%         [beta, ~] = robustfit(X,y,[],[],'off');
%         r = y-X*beta;
   
        % AIC & BIC
        n = length(r);
        LL = -n/2*log(2*pi*var(r))  - n/2;

        bic = -LL + P/2*log(n);
        
    end
    
    if P > 1
        beta = beta0;
    end
    
end

function w = biweight( r )
    c = 4.685;
    sig = mad(r,1)/.6745;

    r = r/sig;
    
    lst = r < c & r > -c;
    w = zeros( size(r) );
    w(lst) = abs(1 - (r(lst)/c).^2);
end
